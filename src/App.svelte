<script>
	import Tailwindcss from './Tailwindcss.svelte';
	import Button from './components/Button.svelte';
	import WrongNetwork from './components/WrongNetwork.svelte';
    import { ethStore, web3, selectedAccount, connected } from 'svelte-web3';
	import Nav from './components/Nav.svelte';
	import Register from './components/Register.svelte';
	import Registered from './components/Registered.svelte';
	import { SvelteToast } from '@zerodevx/svelte-toast'
	import { abi, address } from './_referUser.js';
	import { abi as lpAbi, address as lpAddress } from './_liquidProvider.js';
	import { abi as honeyAbi, address as honeyAddress } from './_honeyToken.js';
	import { lastClaimTime, timeBetweenClaim, currentBlockNumber, accountName, miningProgress, LPBalance, honeyBalance, registerd, approvedAmmount, stakedBalance } from './dataStore.js';

	// Checks
	let wrongNetwork = false;
	
	// Loaders
	let connectWalletLoading = false;

	// Enables the connection to the MetaMask extention
    const enableBrowser = async () => {
        connectWalletLoading = true;

		await ethStore.setBrowserProvider();
        // If user is on wrong network check
		if($web3.eth && await $web3.eth.net.getId() !== 777) {
            console.log("Wrong chain - Change MetaMask to cheapETH (cheapeth.org)");
			wrongNetwork = true;
        }

        connectWalletLoading = false;

        // Updates any values that may have changed in the new block
        $web3.eth.subscribe('newBlockHeaders', async function(error, result) {
			if($connected){
				updateStores();
			}
		})
		updateStores();
    }
	enableBrowser();

	// Check referral code exsists while typing
    const getIsRegistered = async(val) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.getNameFromAddress(val).call().then(function(res) {
			return res;
		});
	}
	const getSelectedAccountHoneyBalance = async(e) => {
		let contract = new $web3.eth.Contract(honeyAbi, honeyAddress);
		return contract.methods.balanceOf($selectedAccount).call().then(function(res) {
			return res;
		});
	}
	const getSelectedAccountLPBalance = async(e) => {
		let contract = new $web3.eth.Contract(lpAbi, lpAddress);
		return contract.methods.balanceOf($selectedAccount).call().then(function(res) {
			return res;
		});
	}
	const getSelectedAccountApproval = async(e) => {
		let contract = new $web3.eth.Contract(lpAbi, lpAddress);
		return contract.methods.allowance($selectedAccount, address).call().then(function(res) {
			return res;
		});
	}

	const getSelectedAccountTotalStake = async(e) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.getTotalStakedFromAddress($selectedAccount).call().then(function(res) {
			return res;
		});
	}
	const getSelectedAccountMiningProgress = async(e) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.getMiningProgressFromAddress($selectedAccount).call().then(function(res) {
			return res;
		});
	}

	const getNameFromAddress = async(e) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.getNameFromAddress($selectedAccount).call().then(function(res) {
			return res;
		});
	}
	const updateStores = async () => {
		registerd.set(await getIsRegistered($selectedAccount) !== "");
		
		let hnybal = await getSelectedAccountHoneyBalance();
		honeyBalance.set($web3.utils.fromWei(hnybal.toString()));
		
		if($registerd){

			let approvalAmount = await getSelectedAccountApproval();
			approvedAmmount.set($web3.utils.fromWei(approvalAmount.toString()));

			let lpbal = await getSelectedAccountLPBalance();
			LPBalance.set($web3.utils.fromWei(lpbal.toString()));

			let acntName = await getNameFromAddress();
			accountName.set(acntName.toString());

			let { lastClaim , timeBetween, currentBlock } = await getSelectedAccountMiningProgress();

			let output = ((currentBlock - lastClaim) * 100) / timeBetween;
			if(output >= 100){
				output = 100;
			}
			miningProgress.set(output);
			lastClaimTime.set(lastClaim)
			timeBetweenClaim.set(timeBetween)
			currentBlockNumber.set(currentBlock)

			if($approvedAmmount > 0){
				
				let totStake = await getSelectedAccountTotalStake();
				stakedBalance.set($web3.utils.fromWei(totStake.toString()));
				
			}
		}
			
		console.log("STORES:", 
			"Reg", $registerd, 
			"hnyBal",$honeyBalance, 
			"ApproveAmt",$approvedAmmount, 
			"lpBal",$LPBalance,
			"totStake", $stakedBalance,
			"mineProgress", $miningProgress
		)
	}

	const options = {

	}

</script>

<svelte:head>
	<style>
		body {
			height: 100%;
			background-image: url("BGBUBBLES.svg");
			background-repeat: no-repeat;
			background-position: center;			
			background-size: cover;
		}
	</style>
</svelte:head>
<SvelteToast {options} />
<Tailwindcss />
{#if wrongNetwork}
	<WrongNetwork />
{/if}

<main class="">
	<nav class="mt-16 mx-60">
		<Nav />
	</nav>
	<div class="flex flex-col mt-5 justify-center items-center">
		<div class="mt-5">
			{#if $connected}
			{#if $registerd}
			<Registered/>
			{:else}
			<Register />
			{/if}
			{:else}
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Connect Wallet</Button>
			{/if}
		</div>
	</div>
</main>

<style>
</style>
