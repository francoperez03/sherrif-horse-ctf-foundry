-include .env

script1:
	forge script script/1.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv
1: 
	forge test --match-contract testContract1 -vvvvv
2: 
	forge test --match-contract testContract2 -vvvvv
3: 
	forge test --match-contract testContract3 -vvvvv
4: 
	forge test --match-contract testContract4 -vvvvv
