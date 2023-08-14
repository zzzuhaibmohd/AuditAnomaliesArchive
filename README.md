## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

Foundry consists of:

### Issue 1
### Denial of Service(DoS) due to hardcoding of DECIMALS

Test

```
forge test --contracts ./test/Issue1.t.sol -vv

```

#### Contract

[Uwerx_exp.sol](src/test/Uwerx_exp.sol)

#### Link Reference

https://twitter.com/deeberiroz/status/1686683788795846657

https://twitter.com/CertiKAlert/status/1686667720920625152

https://etherscan.io/tx/0x3b19e152943f31fe0830b67315ddc89be9a066dc89174256e17bc8c2d35b5af8

---
