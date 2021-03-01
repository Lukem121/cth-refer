<script>
	import Tailwindcss from './Tailwindcss.svelte';
	import Button from './components/Button.svelte';
	import WrongNetwork from './components/WrongNetwork.svelte';
	import TeamMember from './components/TeamMember.svelte';
	import ProgressRing from './components/ProgressRing.svelte';
	import { slide } from 'svelte/transition';
	import abi from './_honeyTokenABI.js';
    import { ethStore, chainId, web3, selectedAccount, connected } from 'svelte-web3';

	let honeyTokenABI = abi;
	let honeyContractAddress= "0x940395C99e6938BF02165461E86DEeaF3ADC6815";

	// Register
	let joinHoneyPrice = 0.01;
	let registerUsername = "";
	let registerReferalCode = "";

	// Checks
	let registerd = false;
	let progress;
	let wrongNetwork = false;
	
	// Loaders
	let connectWalletLoading = false;
	let registerLoading = false;

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
			// DO SOMETHING ON EACH NEW BLOCK
		})        
    }
	enableBrowser();


	// CONTRACT SENDS
	const sendRegisterTransaction = async () => {
		registerLoading = true;
        let contract = new $web3.eth.Contract(abi, honeyContractAddress, { from: $selectedAccount });
        await contract.methods.register(registerUsername, registerReferalCode).send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
            value: $web3.utils.toWei((joinHoneyPrice).toString(), 'ether')
        })
        .then( (receipt) => {
            console.log(receipt);
        });
		registerLoading = false;
    }

	// CONTRACT CALLS
	const getSelectedAccountHoneyBalance = async(e) => {
		let contract = new $web3.eth.Contract(honeyTokenABI, honeyContractAddress);
		return contract.methods.balanceOf($selectedAccount).call().then(function(res) {
			return res;
		});
	}



</script>

<svelte:head>
	<style>
		body {
			height: 70vh;
		}
	</style>
</svelte:head>

<Tailwindcss />
{#if wrongNetwork}
	<WrongNetwork />
{/if}
<div class="flex justify-center items-center md:justify-end">
	<a href="https://cheapswap.io/#/swap?inputCurrency=ETH&outputCurrency={honeyContractAddress}" >
		<div class="flex justify-center items-center cursor-pointer border-2 border-black my-6 mr-1 md:mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
			<p>Get Honey!</p>
		</div>
	</a>
	{#if $connected}
		<div class="flex justify-center items-center cursor-pointer border-2 border-black my-6 mr-0.5 md:mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
			<div class="align-middle pr-3 border-r-2 text-yellow-400 text-sm border-black">
				{#await getSelectedAccountHoneyBalance() }
					...
				{:then balance}
					<p>{parseInt($web3.utils.fromWei(balance))} HNY</p>
				{/await}
			</div>
			<div class="cth pr-3 border-r-2 text-red-600 text-sm border-black">
				{#await $web3.eth.getBalance($selectedAccount)}
					...
				{:then balance}
					<p>{parseInt($web3.utils.fromWei(balance))} CTH</p>
				{/await}
			</div>
			<div class="hidden md:block">
				<p>{ $selectedAccount.slice(0, 6) }...{ $selectedAccount.slice($selectedAccount.length - 4, $selectedAccount.length) }</p>
			</div>
			<div class="sm:block md:hidden">
				<p>{ $selectedAccount.slice(0, 6) }</p>
			</div>
		</div>
	{/if}
</div>

<main class="flex flex-col md:mt-16 justify-center items-center h-full">
	<!-- Logo -->
	<div class="flex justify-center ">
		<div class="pl-9 flex flex-nowrap items-start">
			<h1 class="text-8xl font-bold leading-none">Honey</h1>
			<img class="w-12" src="./logo.svg" alt="logo">
		</div>
	</div>
	<div class="mt-5">
		{#if $connected}
				{#if registerd}
					<div class="flex flex-col justify-center items-center">
						<ProgressRing radius={100} progress={progress} stroke={8} />
						<h2 class="my-2 mb-3"><i class="far fa-clock"></i> 14:44:51</h2>
						<Button on:click={enableBrowser} loading={connectWalletLoading}>Start Mining</Button>
					</div>
					{:else}
					<form on:submit|preventDefault={sendRegisterTransaction} class="flex flex-col justify-center items-center">
						<div class="flex flex-col space-y-2 p-2 mb-1">
							{#if registerReferalCode.length >= 3 }
								<input transition:slide bind:value={registerUsername} required minLength="3" maxLength="18" class="rounded border w-56 shadow border-black px-4 py-1 text-lg" type="text" placeholder="Username">
							{/if}
							<input bind:value={registerReferalCode} required minLength="3" maxLength="18" class="rounded border w-56 shadow border-black px-4 py-1 text-lg" type="text" placeholder="Referral Code">
						</div>
						<Button on:click loading={registerLoading}>Register</Button>
					</form>
				{/if}
			{:else}
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Connect Wallet</Button>
		{/if}
	</div>
	{#if registerd}
	<div class="border-2 w-72 md:w-auto border-black mt-6 p-3 rounded space-y-1 md:space-y-1">
		<h2 class="font-bold">Deposit CTH/HNY LP for reward multiplier</h2>
		<div class="flex space-x-4">
			<p class="text-green-400" >Staked: 3.8</p>
			<p class="text-red-400">Unstaked: 8.1</p>
		</div>
		<div class="flex flex-col items-center md:flex-row space-y-1 md:space-x-4">
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Deposit</Button>
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Withdraw</Button>
		</div>
		<div class="flex justify-center">
			<a href="https://cheapswap.io/#/add/ETH/{honeyContractAddress}">
				<Button>Provide Liquididty</Button>
			</a>
		</div>
	</div>
	<h2 class="mt-6 font-bold text-xl leading-none">Team</h2>
	<h2 class="text-xs">1 x 25% x (0.4 HNY/hr) = 0.10 HNY/hr</h2>
	<div class="team mt-3 grid grid-cols-2 gap-7 sm:gap-5 sm:grid-cols-3">
		<TeamMember />
		<TeamMember />
		<TeamMember mining={false} />
		<TeamMember mining={false} />
		<TeamMember />
		<TeamMember />
		<TeamMember mining={false} />
		<TeamMember />
		<TeamMember />
		<TeamMember />
	</div>
	<input bind:value={progress} type="range" min="0" max="100">
	{/if}
</main>

<style>
	h1 {
		font-family: 'PT Sans', sans-serif;
	}
</style>
