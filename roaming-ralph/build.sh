source ~/local/src/emsdk/emsdk_env.sh

python3.8 freezify.py

if [ $? -eq 0 ]; then
  dunstify "freezify succeeded."
else
  dunstify "freezify failed!"
fi
