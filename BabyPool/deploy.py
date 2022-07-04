import solcx
from solcx import compile_standard
import json

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
