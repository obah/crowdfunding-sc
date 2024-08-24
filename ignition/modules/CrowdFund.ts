import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("CrowdFundModule", (m) => {
  const crowdFund = m.contract("CrowdFund", []);

  return { crowdFund };
});
