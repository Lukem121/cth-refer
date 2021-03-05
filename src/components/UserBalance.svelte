<script>
    import { web3, selectedAccount } from 'svelte-web3';
	import { abi, address } from '../_honeyToken.js';

    const getSelectedAccountHoneyBalance = async(e) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.balanceOf($selectedAccount).call().then(function(res) {
			return res;
		});
	}
</script>

<div class="flex justify-center items-center cursor-pointer border-2 border-black my-6 mr-0.5 md:mr-6 px-3 py-1 rounded-lg space-x-2 font-medium">
    <div class="align-middle pr-3 border-r-2 text-yellow-400 text-sm border-black">
        {#await getSelectedAccountHoneyBalance() }
            ...
        {:then balance}
            {balance}
            {#if $web3.utils.fromWei(balance) < 1}
                <p>{parseFloat($web3.utils.fromWei(balance)).toFixed(3)} HNY</p>
                {:else}
                <p>{parseInt($web3.utils.fromWei(balance))} HNY</p>
            {/if}
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