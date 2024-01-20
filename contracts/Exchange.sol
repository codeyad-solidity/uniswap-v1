pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenAddress;

    constructor(address token) ERC20("Codeyad LP Token", "CYDlpToken") {
        require(token != address(0), "Token address passed is a null address");
        tokenAddress = token;
    }

    function addLiquidity(uint256 amountOfToken) public payable returns (uint256) {
        uint256 lpTokensToMint;
        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenReserveBalance = getReserve();

        ERC20 token = ERC20(tokenAddress);

        if (tokenReserveBalance == 0) {
            token.transferFrom(msg.sender, address(this), amountOfToken);

            lpTokensToMint = ethReserveBalance;

            _mint(msg.sender, lpTokensToMint);

            return lpTokensToMint;
        }

        uint256 ethReservePriorToFunctionCall = ethReserveBalance - msg.value;
        uint256 minTokenAmountRequired = (msg.value * tokenReserveBalance) / ethReservePriorToFunctionCall;

        require(amountOfToken >= minTokenAmountRequired, "Insufficient amount of tokens provided");

        token.transferFrom(msg.sender, address(this), minTokenAmountRequired);

        lpTokensToMint = (totalSupply() * msg.value) / ethReservePriorToFunctionCall;

        _mint(msg.sender, lpTokensToMint);

        return lpTokensToMint;
    }

     function removeLiquidity(uint256 amountOfLPTokens) public returns (uint256, uint256) {
        require(amountOfLPTokens > 0, "Amount of tokens to remove must be greater than zero");

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokenTotalSupply = totalSupply();

        uint256 ethToReturn = (ethReserveBalance * amountOfLPTokens) / lpTokenTotalSupply;
        uint256 tokenToReturn = (getReserve() * amountOfLPTokens) / lpTokenTotalSupply;

        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(tokenAddress).transfer(msg.sender, tokenToReturn);

        return (ethToReturn, tokenToReturn);
    }

    function getReserve() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }
}
