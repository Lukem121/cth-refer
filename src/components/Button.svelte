<script>
	export let loading;
	export let disabled;
</script>

<button class:opacity-50={disabled} disabled={ disabled || loading } on:click class="rounded-xl border-4 w-56 bg-luke-green shadow border-black px-8 py-1 font-bold text-lg" >
    {#if loading}
        <i class="fas fa-sync-alt animate-spin"></i>
		{:else}
            <slot></slot>
	{/if}
</button>