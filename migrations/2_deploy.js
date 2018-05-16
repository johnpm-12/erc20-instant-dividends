var InstantDividendsToken = artifacts.require('InstantDividendsToken');

module.exports = function (deployer) {
    deployer.deploy(InstantDividendsToken, 'Test Token', 'TEST', 18, 1e30);
};
