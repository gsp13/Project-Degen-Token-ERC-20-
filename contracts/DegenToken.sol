// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract DegenToken is ERC20, ERC20Burnable,Ownable {

/*
Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
Transferring tokens: Players should be able to transfer their tokens to others.
Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
Checking token balance: Players should be able to check their token balance at any time.
Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/

    struct Item{
        string itemName;
        uint256 itemPrice;
        string itemDesc;
    }
    
    Item[] public _storeItems;
    mapping (address=>string[])  private _accountPurchases;   

    constructor() ERC20("Degen", "DGN") {
        addStoreItem(Item("Abaddon The Despoiler",1000,"Under his rule, there is but one creed: Chaos shall reign."));
        addStoreItem(Item("Yoshimaru, Ever Faithful",3500,"Day after day he sat there, knowing that the Wanderer would soon be back for him."));
        addStoreItem(Item("Richard Garfield, Ph.D.",99999,"And yea he doth spake: 'Let there be Magic.'"));
    }
    function addStoreItem(Item memory _item) public{
        _storeItems.push(_item);
    }
   function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * 10  ** decimals());
    }
    function burn(uint256 tokenAmount) override public {
        require(balanceOf(msg.sender)>= (tokenAmount* 10  ** decimals()),"You cannot burn the specified token amount given your account balance");
        _burn(msg.sender,tokenAmount * 10  ** decimals());
    }
    function transferTokens(address _receiver, uint256 _tokenAmount) public{
        uint256 convertedAmount=_tokenAmount* 10  ** decimals();
        require (balanceOf(msg.sender)>= convertedAmount ,"Your DGN token balance is insufficient for conducting a successful transaction.");
        approve(msg.sender,_tokenAmount);
        transfer(_receiver,convertedAmount);

    }

    function checkTokenBalance() external view returns (uint256){
        return balanceOf(msg.sender)/( 10  ** decimals());
    }

    function displayAvailableItems() external view returns(string memory){
        string memory result="Name     Price     Description";
        for (uint i = 0; i < _storeItems.length; i++) {
           
                string memory itemID= Strings.toString(i+1);
                result= string.concat(result,"\n",
                                    itemID,
                                    _storeItems[i].itemName,
                                    " ",
                                    Strings.toString(_storeItems[i].itemPrice),
                                    " ",
                                    _storeItems[i].itemDesc
                                );
            
        }
        return result;
    }
    
    function displayPurchases() external view returns(string[] memory){
        return _accountPurchases[msg.sender];
    }
     function redeemTokens(uint itemID) external payable returns (string memory) {
        require(itemID>0 && itemID<=_storeItems.length,"Invalid Item ID"); 
        Item memory selectedItem= _storeItems[itemID-1];
        require((balanceOf(msg.sender)) >=(selectedItem.itemPrice * 10  ** decimals()) ,"You do not have enough tokens to redeem this item");
        approve(msg.sender, selectedItem.itemPrice);
        transferTokens(owner(),selectedItem.itemPrice);
        _accountPurchases[msg.sender].push(selectedItem.itemName);
        return string.concat("Purchased Item ID:",Strings.toString(itemID-1));
     }
}
