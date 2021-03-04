<script>
	import Button from './Button.svelte';
	import { slide } from 'svelte/transition';
    import { ethStore, chainId, web3, selectedAccount, connected } from 'svelte-web3';

    // Register
	let joinHoneyPrice = 0.01;
	let registerUsername = "";
	let registerReferalCode = "";

    //Loaders
	let registerLoading = false;



    const sendRegisterTransaction = async () => {
		registerLoading = true;

		//REMOVE THIS CODE BELOW
		registerd = true;

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
</script>

<form on:submit|preventDefault={sendRegisterTransaction} class="flex flex-col justify-center items-center">
    <div class="flex flex-col space-y-2 p-2 mb-1">
        {#if registerReferalCode.length >= 3 }
            <input transition:slide bind:value={registerUsername} required minLength="3" name="username" maxLength="18" class="rounded border w-56 shadow border-black px-4 py-1 text-lg" type="text" placeholder="Username">
        {/if}
        <input bind:value={registerReferalCode} required minLength="3" maxLength="18" class="rounded border w-56 shadow text-yellow-400 placeholder-yellow-300 border-black  px-4 py-1 text-lg" type="text" placeholder="Referral Code">
    </div>
    <Button on:click loading={registerLoading}>Register</Button>
</form>