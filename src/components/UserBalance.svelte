<script>
    import { web3, selectedAccount } from 'svelte-web3';
	import { abi, address } from '../_honeyToken.js';
	import { honeyBalance, registerd } from '../dataStore.js';
</script>

<!-- <div class="flex justify-center items-center cursor-pointer border-2 border-black my-6 mr-0.5 md:mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
    <div class="align-middle pr-3 border-r-2 text-yellow-400 text-sm border-black">
        {#if $honeyBalance < 1}
            <p>{$honeyBalance} HNY</p>
            {:else}
            <p>{$honeyBalance} HNY</p>
        {/if}
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
</div> -->

<div class="flex items-center space-x-3">
    <div class="harvest-balance leading-none harvest-gradient py-2 px-4 rounded-2xl">
        {#if $honeyBalance < 1}
            <p class="font-bold" >{$honeyBalance} HRVST</p>
            {:else}
            <p class="font-bold" >{$honeyBalance} HRVST</p>
        {/if}
    </div>
    <div class="bg-harvest-blue font-bold leading-none items-center text-white flex rounded-lg">
        {#await $web3.eth.getBalance($selectedAccount)}
            ...
        {:then balance}
            <p class="px-6" >{parseInt($web3.utils.fromWei(balance))} CTH</p>
        {/await}
        <div class="bg-harvest-blue-dark leading-none py-2 px-6 rounded-lg">
            <div class="hidden md:block">
                <p>{ $selectedAccount.slice(0, 6) }...{ $selectedAccount.slice($selectedAccount.length - 4, $selectedAccount.length) }</p>
            </div>
            <div class="sm:block md:hidden">
                <p>{ $selectedAccount.slice(0, 6) }</p>
            </div>
        </div>
    </div>
</div>

<style lang="postcss">
    .harvest-gradient {
        @apply bg-gradient-to-br from-harvest-green via-harvest-green-light to-harvest-green-dark;
    }
</style>