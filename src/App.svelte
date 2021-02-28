<script>
	import Tailwindcss from './Tailwindcss.svelte';
	import Button from './components/Button.svelte';
	import WrongNetwork from './components/WrongNetwork.svelte';
	import TeamMember from './components/TeamMember.svelte';
	import ProgressRing from './components/ProgressRing.svelte';
	import abi from './_honeyTokenABI.js';
    import { ethStore, chainId, web3, selectedAccount, connected } from 'svelte-web3';

	let honeyTokenABI = abi;
	let honeyContractAddress= "0x4A43400245BD1F21C0ee6f6f333Bec91f206Bafe";

	// Checks
	let registerd = true;
	let progress;
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
			// DO SOMETHING ON EACH NEW BLOCK
		})        
    }
	enableBrowser();


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
			height: 100vh;
		}
	</style>
</svelte:head>

<Tailwindcss />
{#if wrongNetwork}
	<WrongNetwork />
{/if}

	<div class="flex justify-center md:justify-end">
		<a href="https://cheapswap.io/#/swap?inputCurrency=ETH&outputCurrency={honeyContractAddress}" class="flex cursor-pointer border-2 border-black my-6 mx-2 px-3 py-1 rounded-lg space-x-2 font-medium">
			Get Honey!
		</a>
		{#if $connected}
			<div class="flex cursor-pointer border-2 border-black my-6 mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
				<div class="hny pr-3 border-r-2 text-yellow-400 border-black">
					{#await getSelectedAccountHoneyBalance() }
						...
					{:then balance}
						<p>{parseInt($web3.utils.fromWei(balance))} HNY</p>
					{/await}
				</div>
				<div class="cth pr-3 border-r-2 text-red-600 border-black">
					{#await $web3.eth.getBalance($selectedAccount)}
						...
					{:then balance}
						<p>{parseInt($web3.utils.fromWei(balance))} CTH</p>
					{/await}
				</div>
				<div class="addr">
					<!-- Swap for user address -->
					{ $selectedAccount.slice(0, 6) }...{ $selectedAccount.slice($selectedAccount.length - 4, $selectedAccount.length) }
				</div>
			</div>
		{/if}
	</div>

<main class="flex flex-col md:mt-16 justify-center items-center">
	<div class="logo flex justify-center items-start">
		<h1 class="text-8xl font-bold leading-none">Honey</h1>
		<img class="w-12" src="./logo.svg" alt="logo">
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
					<form action="" class="flex flex-col justify-center items-center">
						<div class="flex flex-col space-y-2 p-2 mb-3">
							<input class="rounded border-2 w-56 shadow border-gray-400 px-4 py-1 font-bold text-lg" type="text" placeholder="Username">
							<input class="rounded border-2 w-56 shadow border-gray-400 px-4 py-1 font-bold text-lg" type="text" placeholder="Referal Code">
						</div>
						<Button on:click={enableBrowser} loading={connectWalletLoading}>Register</Button>
					</form>
				{/if}
			{:else}
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Connect Wallet</Button>
		{/if}
	</div>
	<h2 class="mt-6 font-bold text-xl">Team</h2>
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
</main>

<style>
	h1 {
		font-family: 'PT Sans', sans-serif;
	}
</style>
