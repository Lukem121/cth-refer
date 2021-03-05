<script>
	import Tailwindcss from './Tailwindcss.svelte';
	import Button from './components/Button.svelte';
	import WrongNetwork from './components/WrongNetwork.svelte';
    import { ethStore, web3, selectedAccount, connected } from 'svelte-web3';
	import DEVTOOLS from './components/DEVTOOLS.svelte';
	import Nav from './components/Nav.svelte';
	import Register from './components/Register.svelte';
	import Registered from './components/Registered.svelte';
	import { abi, address } from './_referUser.js';



	// Devtools
	let progress;

	// Checks
	let registerd = false;
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
			if(!registerd){
				registerd = await getIsRegistered($selectedAccount) !== "";
			}
			console.log(registerd);
		})        
		if($connected){
			console.log(registerd);
			registerd = await getIsRegistered($selectedAccount) !== "";
		}
    }
	enableBrowser();

	// Check referral code exsists while typing
    const getIsRegistered = async(val) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.getNameFromAddress(val).call().then(function(res) {
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
<DEVTOOLS bind:registerd={registerd} bind:progress={progress} />
{#if wrongNetwork}
	<WrongNetwork />
{/if}

<Nav />
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
					<Registered bind:progress={progress} />
					{:else}
					<Register />
				{/if}
			{:else}
			<Button on:click={enableBrowser} loading={connectWalletLoading}>Connect Wallet</Button>
		{/if}
	</div>
</main>

<style>
	h1 {
		font-family: 'PT Sans', sans-serif;
	}
</style>
