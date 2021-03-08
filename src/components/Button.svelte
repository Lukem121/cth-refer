<script>
	export let loading;
	export let disabled;
	export let rounedBottom;
</script>

<button class:t-gray={disabled} disabled={ disabled || loading } on:click 
class="rounded-2xl w-56 bg-harvest-black text-harvest-green px-8 py-3 font-bold text-lg" class:rb={rounedBottom} >
    {#if loading}
        <i class="fas fa-sync-alt animate-spin"></i>
		{:else}
            <slot></slot>
	{/if}
</button>

<style lang="postcss">
	.rb {
		@apply rounded-b-xl rounded-t-none; 
	}

	.t-gray {
		@apply text-gray-400 cursor-not-allowed;
	}
</style>