<script>
	import Button from './Button.svelte';
    import { toast } from '@zerodevx/svelte-toast'
	import TeamMember from './TeamMember.svelte';
	import ProgressRing from './ProgressRing.svelte';
    import { web3, selectedAccount } from 'svelte-web3';
	import { abi, address } from '../_referUser.js';
	import { abi as lpAbi, address as lpAddress } from '../_liquidProvider.js';
	import { abi as honeyAbi, address as honeyAddress } from '../_honeyToken.js';

	import { lastClaimTime , timeBetweenClaim, currentBlockNumber, accountName, miningProgress, stakedBalance, approvedAmmount, LPBalance, honeyBalance } from '../dataStore.js';

    // Loaders
    let stakeLoading = false;
    let withdrawLoading = false;
    let approvalLoading = false;
    let claimLoading = false;

    const getSelectedAccountPagedReferralsFromName = async () => {
        let contract = new $web3.eth.Contract(abi, address);
        let name = $accountName;
        return contract.methods.getPagedReferralsFromName(name, 0, 10).call().then(function(res) {
            return res;
        });
    }

    const getReferral = async (val) => {
        
        let { values , newCursor } = await getSelectedAccountPagedReferralsFromName();

        let allReferrals = [];
        let contract = new $web3.eth.Contract(abi, address);
        for (let i = 0; i < values.length; i++) {

            let address = await contract.methods.getAddressFromName(values[i]).call().then(function(res) {
                return res;
            });
            let isMining = await contract.methods.getActiveFromName(values[i]).call().then(function(res) {
                return res;
            });
            let a = {
                name: values[i],
                address,
                isMining
            }
            allReferrals.push(a);
        }
        console.log("All refurals", allReferrals);
        return allReferrals;

    }

    const sendSelectedAccountClaim = async () => {
        claimLoading = true;

        let contract = new $web3.eth.Contract(abi, address, { from: $selectedAccount });
        await contract.methods.claim().send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .on('confirmation', function(confirmationNumber, receipt){
            if(confirmationNumber == 1){
                toast.push('Mining started! 🥳')
            }
        })
        .on('error', function(error, receipt) {
            if(error.code == 4001){
                toast.push('User rejected transaction 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }else {
                toast.push('Somthing went wrong 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }
            claimLoading = false;
        });
        claimLoading = false;
    }

    const sendSelectedAccountApproval = async () => {
        approvalLoading = true;

        let contract = new $web3.eth.Contract(lpAbi, lpAddress, { from: $selectedAccount });
        await contract.methods.approve(address, "100000000000000000000000").send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .on('confirmation', function(confirmationNumber, receipt){
            if(confirmationNumber == 1){
                toast.push('Approval confirmed')
            }
        })
        .on('error', function(error, receipt) {
            if(error.code == 4001){
                toast.push('User rejected transaction 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }
            approvalLoading = false;
        });
        approvalLoading = false;
        
    }

    const sendStakeRequest = async () => {
        stakeLoading = true;

        let contract = new $web3.eth.Contract(abi, address, { from: $selectedAccount });
        await contract.methods.stake($web3.utils.toWei($LPBalance)).send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .on('confirmation', function(confirmationNumber, receipt){
            if(confirmationNumber == 1){
                toast.push('LP Tokens Staked! 💰')
            }
        })
        .on('error', function(error, receipt) {
            if(error.code == 4001){
                toast.push('User rejected transaction 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }else {
                toast.push('Somthing went wrong 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }
            stakeLoading = false;
        });
        stakeLoading = false;
    }

    const sendWithdrawStakeRequest = async () => {
        withdrawLoading = true;

        let contract = new $web3.eth.Contract(abi, address, { from: $selectedAccount });
        await contract.methods.withdraw($web3.utils.toWei($stakedBalance)).send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .on('confirmation', function(confirmationNumber, receipt){
            if(confirmationNumber == 1){
                toast.push('Withdraw sucsessful! 💰')
            }
        })
        .on('error', function(error, receipt) {
            if(error.code == 4001){
                toast.push('User rejected transaction 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }else {
                toast.push('Somthing went wrong 😢', {
                    theme: {
                        '--toastBackground': '#F56565',
                        '--toastProgressBackground': '#C53030'
                    }
                })
            }
            withdrawLoading = false;
        });
        withdrawLoading = false;
    }

</script>
<div class="flex flex-col justify-center items-center">
    <ProgressRing radius={100} honeyBalance={$honeyBalance} progress={$miningProgress} stroke={8} />
    {#if Number($lastClaimTime) + Number($timeBetweenClaim) < Number($currentBlockNumber)}
        <h2 class="my-2 mb-3"><i class="far fa-clock"></i> Mining Finished</h2>
        {:else}
        <h2 class="my-2 mb-3"><i class="far fa-clock"></i> {(Number($lastClaimTime) + Number($timeBetweenClaim)) - $currentBlockNumber} Blocks Remaining</h2>
    {/if}
    <Button on:click={sendSelectedAccountClaim} loading={claimLoading} disabled={$miningProgress != 100}>Start Mining</Button>
</div>

<div class="border-2 w-72 md:w-auto border-black mt-6 p-3 rounded space-y-1 md:space-y-1">
    <h2 class="font-bold">Deposit CTH/HNY LP for reward multiplier</h2>
    <div class="flex space-x-4">
        <p class="text-green-400" >Staked: {parseFloat($stakedBalance).toFixed(4)}</p>
        <p class="text-red-400">Unstaked: {parseFloat($LPBalance).toFixed(4)}</p>
    </div>
    {#if $approvedAmmount > 0}
        <div class="flex flex-col items-center md:flex-row space-y-1 md:space-x-4">
            <Button loading={stakeLoading} disabled={$LPBalance <= 0} on:click={sendStakeRequest}>Stake</Button>
            <Button loading={withdrawLoading} disabled={$stakedBalance <= 0} on:click={sendWithdrawStakeRequest}>Withdraw</Button>
        </div>
        {:else}
        <div class="flex justify-center">
            <Button loading={approvalLoading} on:click={sendSelectedAccountApproval}>Approve</Button>
        </div>
    {/if}
    <div class="flex justify-center">
        <a href="https://cheapswap.io/#/add/ETH/{address}" target="_blank">
            <Button>Provide Liquididty</Button>
        </a>
    </div>
</div>
<h2 class="mt-6 mb-1 font-bold text-xl leading-none">Team - <span class="text-yellow-400">{$accountName}</span></h2>
<h2 class="text-xs">1 x 25% x (0.4 HNY/hr) = 0.10 HNY/hr</h2>
<h2 class="text-xs">Invite people to join Honey and recive a sweet <br>bonus multiplier when they stake liquididty!</h2>
<div class="team mt-3 grid grid-cols-2 gap-7 sm:gap-5 sm:grid-cols-3">
    {#if $accountName != 0}
        {#await getReferral()}
            <p>...waiting</p>
        {:then arr}
            {#each arr as { name, address, isMining }, i}
                <TeamMember name={name} address={address} mining={isMining} />
            {/each}
        {:catch error}
            <p style="color: red">{error.message}</p>
        {/await}
    {/if}
</div>