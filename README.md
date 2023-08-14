## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

[20230814 Issue#1](#20230726-carson---price-manipulation)

### Issue 1 - Denial of Service(DoS) due to hardcoding of DECIMALS

Test
```
forge test --contracts ./test/Issue1.t.sol -vv
```

#### Contract
[Vault4626.sol](src/Issue1/Vault4626.sol)

#### Link Reference

---
