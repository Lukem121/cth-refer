<script>
    export let registerd;
    export let progress;

</script>

<div class="absolute top-0 left-0 flex flex-col">
    <button class="border-2 border-red-700 px-4 py-1" on:click={() => registerd = !registerd}>Toggle registerd</button>
    <label for="ringP">Progres Ring</label>
    <input name="ringP" bind:value={progress} type="range" min="0" max="100">
</div>