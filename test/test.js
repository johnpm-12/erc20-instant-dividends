var InstantDividendsToken = artifacts.require('InstantDividendsToken');

contract('InstantDividendsToken', function (accounts) {
    let tokenInstance;
    let supply;
    let initBalance0;
    let initBalance1;
    let initBalance2;
    it('send 1/4 supply to accounts[1]', function () {
        return InstantDividendsToken.deployed().then((res) => {
            tokenInstance = res;
            return tokenInstance.totalSupply();
        }).then((res) => {
            supply = res.valueOf();
            return tokenInstance.transfer(accounts[1], supply / 4, { from: accounts[0] });
        }).then(() => {
            return tokenInstance.balanceOf(accounts[1]);
        }).then((res) => {
            initBalance1 = res.valueOf();
            assert.equal(initBalance1, supply / 4, 'balance of accounts[1] is not 1/4 the supply');
        });
    });
    it('send 1/2 supply to accounts[2]', function () {
        return tokenInstance.transfer(accounts[2], supply / 2, { from: accounts[0] }).then(() => {
            return tokenInstance.balanceOf(accounts[2]);
        }).then((res) => {
            initBalance2 = res.valueOf();
            assert.equal(initBalance2, supply / 2, 'balance of accounts[2] is not half the supply');
        });
    });
    it('pay dividends of remaining balance (1/4 supply) from accounts[0]', function () {
        return tokenInstance.balanceOf(accounts[0]).then((res) => {
            initBalance0 = res.valueOf();
            return tokenInstance.newDividends(initBalance0, { from: accounts[0] });
        }).then(() => {
            return tokenInstance.balanceOf(accounts[0]);
        }).then((res) => {
            console.log(initBalance0);
            console.log(res.valueOf());
            assert.equal(res.valueOf(), 0, 'balance of accounts[0] is wrong');
            return tokenInstance.balanceOf(accounts[1]);
        }).then((res) => {
            console.log(initBalance1);
            console.log(res.valueOf());
            assert.equal(res.valueOf(), supply / 3, 'balance of accounts[1] is wrong');
            return tokenInstance.balanceOf(accounts[2]);
        }).then((res) => {
            console.log(initBalance2);
            console.log(res.valueOf());
            assert.equal(res.valueOf(), supply * 2 / 3, 'balance of accounts[2] is wrong');
        });
    });
    it('collect fees of 1/4 total supply to accounts[0]', function () {
        // console.log(supply / 4);
        return tokenInstance.newFee(supply / 2, { from: accounts[0] }).then(() => {
            return tokenInstance.balanceOf(accounts[0]);
        }).then((res) => {
            console.log(initBalance0);
            console.log(res.valueOf());
            // assert.equal(res.valueOf(), initBalance0, 'balance of accounts[0] is wrong');
            return tokenInstance.balanceOf(accounts[1]);
        }).then((res) => {
            console.log(initBalance1);
            console.log(res.valueOf());
            // assert.equal(res.valueOf(), initBalance1, 'balance of accounts[1] is wrong');
            return tokenInstance.balanceOf(accounts[2]);
        }).then((res) => {
            console.log(initBalance2);
            console.log(res.valueOf());
            // assert.equal(res.valueOf(), initBalance2, 'balance of accounts[2] is wrong');
        });
    });
});
