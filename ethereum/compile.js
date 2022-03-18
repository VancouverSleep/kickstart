const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

const buildPath = path.resolve(__dirname, "build");

//clear build folder
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, "contracts", "Campaign.sol");
const source = fs.readFileSync(campaignPath, "utf8");

//compile both contracts
const output = solc.compile(source, 1).contracts;

//ensure build folder exists, if not create
fs.ensureDirSync(buildPath);

for (let contract in output) {
	fs.outputJSONSync(
		path.resolve(buildPath, contract.replace(":", "") + ".json"),
		output[contract]
	);
}
