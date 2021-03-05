<script>
	import Button from './Button.svelte';
	import { slide, fade } from 'svelte/transition';
    import { ethStore, chainId, web3, selectedAccount, connected } from 'svelte-web3';
	import { abi, address } from '../_referUser.js';


    // Register
	let joinHoneyPrice = 0.01;
	let registerUsername = "";
	let registerReferalCode = "";
    let referralUsernameExsists = false;
    let referralCodeExsists = false;

    //Loaders
	let registerLoading = false;

    // Set if refural code exsists
    const setReferralCodeExsists = async () => {
        referralCodeExsists = !(await getUsernameAvailable(registerReferalCode));
    }
    // Set if username exsists
    const setReferralUsernameExsists = async () => {
        referralUsernameExsists = (await getUsernameAvailable(registerUsername));
    }
    
    // Check referral code exsists while typing
    const getUsernameAvailable = async(val) => {
		let contract = new $web3.eth.Contract(abi, address);
		return contract.methods.isAvailable(val).call().then(function(res) {
			return res;
		});
	}

    const sendRegisterTransaction = async () => {
		registerLoading = true;

        let contract = new $web3.eth.Contract(abi, address, { from: $selectedAccount });
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
        <div class="relative">
            {#if referralCodeExsists }
                <input transition:slide bind:value={registerUsername} on:input={setReferralUsernameExsists} required minLength="3" name="username" maxLength="18" class="rounded border w-56 shadow border-black px-4 py-1 text-lg" type="text" placeholder="Username">
                {#if !referralUsernameExsists && registerUsername}
                    <div class="absolute top-1.5 -right-8">
                        <div transition:fade class="flex items-center justify-center rounded-full bg-red-100 mx-0 h-7 w-7">
                            <i class="fas fa-times text-red-700"></i>
                        </div>
                    </div>
                    <div class="absolute top-2 -right-32">
                        <span class="pl-2"> Not Available</span>
                    </div>
                    {:else if registerUsername}
                    <div class="absolute top-1.5 -right-8">
                        <div transition:fade class="flex items-center justify-center rounded-full bg-green-100 mx-0 h-7 w-7">
                            <i class="fas fa-check text-green-500 text-sm"></i>
                        </div>
                    </div>
                {/if}
            {/if}
        </div>
        
        <div class="relative">
            <input bind:value={registerReferalCode} on:input={setReferralCodeExsists} required minLength="3" maxLength="18" class="rounded border w-56 shadow text-yellow-400 placeholder-yellow-300 border-black  px-4 py-1 text-lg" type="text" placeholder="Referral Code">
            {#if !referralCodeExsists && registerReferalCode}
                <div class="absolute top-1.5 -right-8">
                    <div transition:fade class="flex items-center justify-center rounded-full bg-red-100 mx-0 h-7 w-7">
                        <i class="fas fa-times text-red-700"></i>
                    </div>
                </div>
                {:else if registerReferalCode}
                <div class="absolute top-1.5 -right-8">
                    <div transition:fade class="flex items-center justify-center rounded-full bg-green-100 mx-0 h-7 w-7">
                        <i class="fas fa-check text-green-500 text-sm"></i>
                    </div>
                </div>
            {/if}
        </div>
    </div>
    <Button on:click loading={registerLoading} disabled={!(registerReferalCode && (referralUsernameExsists && registerUsername))} >Register</Button>
</form>