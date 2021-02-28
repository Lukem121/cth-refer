<script>
    export let username = "Lukem121";
    export let address = "0x0f8C4EC2f0D68602E79571199a79F52F70ae75a4";
    export let mining = true;
</script>

<div class="attack flex items-center space-x-3">
    <div class:bg-green-100={mining} class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
        {#if mining}
            <i class="fas fa-check"></i>
            {:else}
            <svg class="h-6 w-6 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
        {/if}
      </div>
    <div class="info">
        <h2>
            { username }
        </h2>
        <h2>
            { address.slice(0, 6) }...{ address.slice(address.length - 4, address.length) }
        </h2>
    </div>
</div>