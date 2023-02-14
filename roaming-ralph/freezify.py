from direct.dist import FreezeTool
import sys, os

if sys.version_info[:2] != (3, 8):
    sys.exit("Run this with Python 3.8, or edit this script")

# Thirdparty libraries
THIRDPARTY_DIR = "/home/rdb/panda3d-webgl/thirdparty/emscripten-libs"

# Python extension modules
PY_MODULE_DIR = THIRDPARTY_DIR + "/python/lib/python3.8/lib-dynload"
PY_STDLIB_DIR = THIRDPARTY_DIR + "/python/lib/python3.8"
PY_MODULES = []

# Panda modules / libraries
PANDA_BUILT_DIR = "/home/rdb/panda3d-webgl/built"
PANDA_MODULES = ["core", "direct"]
PANDA_LIBS = ["libp3interrogatedb", "libpanda", "libpandaexpress", "libp3dtool", "libp3dtoolconfig", "libp3webgldisplay", "libp3direct", "libp3openal_audio"]
PANDA_STATIC = True # built with --static

# Increase this when emscripten complains about running out of memory
TOTAL_MEMORY = 50331648

# Increase this to get useful debugging info when crashes occur
ASSERTIONS = 0

# Files to preload into the virtual filesystem
# You don't need to preload these files anymore, Panda3D will happily read them
# from the web server instead, but preloading is considerably more efficient.
PRELOAD_FILES = [
    "models/ground.jpg",
    "models/hedge.jpg",
    "models/ralph.bam",
    "models/ralph.jpg",
    "models/ralph-run.bam",
    "models/ralph-walk.bam",
    "models/rock03.jpg",
    "models/tree.jpg",
    "models/world.bam",
]


class EmscriptenEnvironment:
    platform = 'emscripten'

    pythonInc = THIRDPARTY_DIR + "/python/include/python3.8"
    pythonLib = THIRDPARTY_DIR + "/python/lib/libpython3.8.a"

    modStr = " ".join((os.path.join(PY_MODULE_DIR, a + ".cpython-38.o") for a in PY_MODULES))

    pandaFlags = ""
    for mod in PANDA_MODULES:
        if PANDA_STATIC:
            pandaFlags += f" {PANDA_BUILT_DIR}/lib/libpy.panda3d.{mod}.a"
        else:
            pandaFlags += f" {PANDA_BUILT_DIR}/panda3d/{mod}.o"

    for lib in PANDA_LIBS:
        pandaFlags += f" {PANDA_BUILT_DIR}/lib/{lib}.a"

    pandaFlags += f" -I{PANDA_BUILT_DIR}/include"
    pandaFlags += " -s USE_ZLIB=1 -s USE_VORBIS=1 -s USE_LIBPNG=1 -s USE_FREETYPE=1 -s USE_HARFBUZZ=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s DISABLE_EXCEPTION_THROWING=0 "

    for file in PRELOAD_FILES:
        pandaFlags += " --preload-file " + file

    compileObj = f"emcc -O3 -fno-exceptions -fno-rtti -c -o %(basename)s.o %(filename)s -I{pythonInc}"
    linkExe = f"emcc -O3 -s TOTAL_MEMORY={TOTAL_MEMORY} -s ASSERTIONS={ASSERTIONS} -s MAX_WEBGL_VERSION=2 -s NO_EXIT_RUNTIME=1 -fno-exceptions -fno-rtti -o %(basename)s.js %(basename)s.o {modStr} {pythonLib} {pandaFlags}"
    linkDll = f"emcc -O2 -shared -o %(basename)s.o %(basename)s.o {pythonLib}"

    # Paths to Python stuff.
    Python = None
    PythonIPath = pythonInc
    PythonVersion = "3.8"

    suffix64 = ''
    dllext = ''
    arch = ''

    def compileExe(self, filename, basename, extraLink=[]):
        compile = self.compileObj % {
            'python' : self.Python,
            'filename' : filename,
            'basename' : basename,
            }
        print(compile, file=sys.stderr)
        if os.system(compile) != 0:
            raise Exception('failed to compile %s.' % basename)

        link = self.linkExe % {
            'python' : self.Python,
            'filename' : filename,
            'basename' : basename,
            }
        link += ' ' + ' '.join(extraLink)
        print(link, file=sys.stderr)
        if os.system(link) != 0:
            raise Exception('failed to link %s.' % basename)

    def compileDll(self, filename, basename, extraLink=[]):
        compile = self.compileObj % {
            'python' : self.Python,
            'filename' : filename,
            'basename' : basename,
            }
        print(compile, file=sys.stderr)
        if os.system(compile) != 0:
            raise Exception('failed to compile %s.' % basename)

        link = self.linkDll % {
            'python' : self.Python,
            'filename' : filename,
            'basename' : basename,
            'dllext' : self.dllext,
            }
        link += ' ' + ' '.join(extraLink)
        print(link, file=sys.stderr)
        if os.system(link) != 0:
            raise Exception('failed to link %s.' % basename)


freezer = FreezeTool.Freezer()
freezer.frozenMainCode = """
#include "Python.h"
#include <emscripten.h>

extern PyObject *PyInit_core();
extern PyObject *PyInit_direct();

extern void init_libOpenALAudio();
extern void init_libpnmimagetypes();
extern void init_libwebgldisplay();

extern void task_manager_poll();

int
Py_FrozenMain(int argc, char **argv)
{
    Py_VerboseFlag = 0;
    Py_FrozenFlag = 1; /* Suppress errors from getpath.c */
    Py_DontWriteBytecodeFlag = 1;
    Py_NoSiteFlag = 1;
    Py_NoUserSiteDirectory = 1;
    Py_UnbufferedStdioFlag = 1;

    Py_InitializeEx(0);

    fprintf(stderr, "Python %s\\n",
        Py_GetVersion());

    PyObject *panda3d_module = PyImport_AddModule("panda3d");
    PyModule_AddStringConstant(panda3d_module, "__package__", "panda3d");
    PyModule_AddObject(panda3d_module, "__path__", PyList_New(0));

    PyObject *panda3d_dict = PyModule_GetDict(panda3d_module);

    PyObject *core_module = PyInit_core();
    PyDict_SetItemString(panda3d_dict, "core", core_module);

    PyObject *direct_module = PyInit_direct();
    PyDict_SetItemString(panda3d_dict, "direct", direct_module);

    //PyObject *physics_module = PyInit_physics();
    //PyDict_SetItemString(panda3d_dict, "physics", physics_module);

    PyObject *sys_modules = PySys_GetObject("modules");
    PyDict_SetItemString(sys_modules, "panda3d.core", core_module);
    PyDict_SetItemString(sys_modules, "panda3d.direct", direct_module);

    init_libOpenALAudio();
    init_libpnmimagetypes();
    init_libwebgldisplay();

    emscripten_set_main_loop(&task_manager_poll, 0, 0);

    if (PyImport_ImportFrozenModule("__main__") < 0) {
        PyErr_Print();
        return 1;
    }

    return 0;
}
"""

freezer.moduleSearchPath = [PANDA_BUILT_DIR, PY_STDLIB_DIR, PY_MODULE_DIR]

# Set this to keep the intermediate .c and .o file
#freezer.keepTemporaryFiles = True

freezer.cenv = EmscriptenEnvironment()
freezer.excludeModule('doctest')
freezer.excludeModule('difflib')
freezer.excludeModule('panda3d')
freezer.addModule('__main__', filename="main.py")

freezer.done(addStartupModules=True)
freezer.generateCode("roaming-ralph", compileToExe=True)

#for i in freezer.extras:
#    print(i)

#for i in freezer.modules.keys():
#    print(i)
