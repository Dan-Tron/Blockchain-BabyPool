import solcx
from solcx import compile_standard
import json
from web3 import Web3

solcx.install_solc("0.8.15")

with open("./contracts/BabyPool.sol", "r") as f:
    baby_pool_file = f.read()

# Compile Our Solidity

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"BabyPool.sol": {"content": baby_pool_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "evm.bytecode.object", "metadata", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.8.15",
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["BabyPool.sol"]["BabyPool"]["evm"]["bytecode"][
    "object"
]

# get abi
abi = compiled_sol["contracts"]["BabyPool.sol"]["BabyPool"]["abi"]

# for connecting to ganache
w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:7545"))
chain_id = 1337
my_address = "0xB978E00B4A6c9b6bC2D83650C36C875796e6F831"
private_key = "0xda96803408dcd6c06b0780c9502e8ab2f691cfae2d395f8f930b329f2f0c0dd2"

# create the contract in python
BabyPool = w3.eth.contract(abi=abi, bytecode=bytecode)
print(BabyPool)
