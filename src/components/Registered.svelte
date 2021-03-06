<script>
	import Button from './Button.svelte';
	import TeamMember from './TeamMember.svelte';
	import ProgressRing from './ProgressRing.svelte';
    import { web3, selectedAccount } from 'svelte-web3';
	import { abi, address } from '../_referUser.js';
	import { abi as lpAbi, address as lpAddress } from '../_liquidProvider.js';
	import { abi as honeyAbi, address as honeyAddress } from '../_honeyToken.js';

	import { approvedAmmount, LPBalance, honeyBalance } from '../dataStore.js';

	export let progress;

    // Loaders
    let stakeLoading = false;
    let withdrawLoading = false;
    let approvalLoading = false;

    const sendSelectedAccountApproval = async () => {
        approvalLoading = true;

        let contract = new $web3.eth.Contract(lpAbi, lpAddress, { from: $selectedAccount });
        await contract.methods.approve(address, "100000000000000000000000").send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .then( (receipt) => {
            console.log(receipt);
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
        .then( (receipt) => {
            console.log(receipt);
        });
        stakeLoading = false;
    }

    const sendWithdrawStakeRequest = async () => {
        withdrawLoading = true;

        let contract = new $web3.eth.Contract(abi, address, { from: $selectedAccount });
        await contract.methods.withdraw($web3.utils.toWei($LPBalance)).send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
        })
        .then( (receipt) => {
            console.log(receipt);
        });
        withdrawLoading = false;
    }

</script>

<div class="flex flex-col justify-center items-center">
    <ProgressRing radius={100} honeyBalance={$honeyBalance} progress={progress} stroke={8} />
    <h2 class="my-2 mb-3"><i class="far fa-clock"></i> 14:44:51</h2>
    <Button>Start Mining</Button>
</div>

<div class="border-2 w-72 md:w-auto border-black mt-6 p-3 rounded space-y-1 md:space-y-1">
    <h2 class="font-bold">Deposit CTH/HNY LP for reward multiplier</h2>
    <div class="flex space-x-4">
        <p class="text-green-400" >Staked: 3.8</p>
        <p class="text-red-400">Unstaked: {parseFloat($LPBalance).toFixed()}</p>
    </div>
    {#if $approvedAmmount > 0}
        <div class="flex flex-col items-center md:flex-row space-y-1 md:space-x-4">
            <Button loading={stakeLoading} on:click={sendStakeRequest}>Stake</Button>
            <Button loading={withdrawLoading} on:click={sendWithdrawStakeRequest}>Withdraw</Button>
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
<h2 class="mt-6 font-bold text-xl leading-none">Team</h2>
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