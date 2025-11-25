require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { ethers } = require('ethers');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 3000;
const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const FLASH_CONTRACT_ADDRESS = process.env.FLASH_CONTRACT_ADDRESS;

const ABI = [
  "function startFlashLoan(address asset, uint256 amount, address relayer, uint256 reimbursement, bytes calldata userData) external"
];

if (!RPC_URL) { console.error("RPC_URL missing"); process.exit(1); }

let provider = new ethers.JsonRpcProvider(RPC_URL);
let wallet;
if (PRIVATE_KEY) wallet = new ethers.Wallet(PRIVATE_KEY, provider);
else wallet = provider.getSigner();

const flash = new ethers.Contract(FLASH_CONTRACT_ADDRESS || ethers.ZeroAddress, ABI, wallet);

app.get('/status', async (_, res) => {
  try {
    const block = await provider.getBlockNumber();
    res.json({ ok:true, block });
  } catch (e) { res.status(500).json({ ok:false, error:e.message }); }
});

app.post('/start', async (req, res) => {
  try {
    const { initiator, amount } = req.body;
    const tx = await flash.startFlashLoan(
      ethers.ZeroAddress,
      ethers.parseEther(String(amount)),
      initiator,
      0,
      "0x",
      { gasLimit: 9000000 }
    );
    const rcpt = await tx.wait();
    res.json({ ok:true, tx:tx.hash, block:rcpt.blockNumber });
  } catch (e) { res.status(500).json({ ok:false, error:e.message }); }
});

app.listen(PORT, () => console.log("Backend running on " + PORT));
