<script>
	import Tailwindcss from './Tailwindcss.svelte';
	import Button from './components/Button.svelte';
	import TeamMember from './components/TeamMember.svelte';
	import ProgressRing from './components/ProgressRing.svelte';
    import { ethStore, chainId, web3, selectedAccount, connected } from 'svelte-web3';
	// Checks
	let registerd = true;
	let progress;
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
			// DO SOMETHING
		})        
    }
	enableBrowser();
</script>

<svelte:head>
	<style>
		body {
			height: 100vh;
		}
	</style>
</svelte:head>

<Tailwindcss />
<main class="flex flex-col justify-center mt-11 md:mt-0 items-center h-full">
	<h1 class="text-8xl font-bold leading-none">Honey</h1>
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
