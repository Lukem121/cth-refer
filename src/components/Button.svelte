<script>
	export let loading;
	export let disabled;
</script>

<button class:opacity-50={disabled} disabled={ disabled || loading } on:click class="rounded border-2 w-56 shadow border-black px-8 py-1 font-bold text-lg" >
    {#if loading}
        <i class="fas fa-sync-alt animate-spin"></i>
		{:else}
            <slot></slot>
	{/if}
</button>