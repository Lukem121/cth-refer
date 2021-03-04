<script>
    import { connected } from 'svelte-web3';
	import UserBalance from './UserBalance.svelte';
	import { address } from '../_honeyToken.js';
</script>
<div class="flex justify-center items-center md:justify-end">
	<a href="https://cheapswap.io/#/swap?inputCurrency=ETH&outputCurrency={address}" >
		<div class="flex justify-center items-center cursor-pointer border-2 border-black my-6 mr-1 md:mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
			<p>Get Honey!</p>
		</div>
	</a>
	{#if $connected}
		<UserBalance />
	{/if}
</div>