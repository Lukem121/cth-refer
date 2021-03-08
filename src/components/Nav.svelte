<script>
    import { connected } from 'svelte-web3';
	import UserBalance from './UserBalance.svelte';
	import { address } from '../_honeyToken.js';
	import { showFAQ } from '../dataStore.js';

	const toggleFAQ = () => {
		showFAQ.update( (v) => !v );
	}
</script>
<div class="flex justify-center items-center md:justify-between">
	<img class="w-64" src="HarvestLogo.svg" alt="">
	<div class="flex">
		<a href="https://cheapswap.io/#/swap?inputCurrency=ETH&outputCurrency={address}" >
			<div class="harvest-balance text-white leading-none bg-harvest-blue mr-3 py-2 px-4 rounded-2xl">
				<p class="font-bold">BUY HRVST</p>
			</div>
		</a>
		{#if $connected}
			<UserBalance />
		{/if}
		<div class="flex justify-center items-center text-2xl cursor-pointer" on:click={toggleFAQ}>
			<i class="fas fa-question-circle"></i>
		</div>
	</div>
</div>