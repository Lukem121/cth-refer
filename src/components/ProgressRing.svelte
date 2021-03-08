<script>
    import { onMount } from 'svelte';

    export let radius = 0;
    export let progress = 0;
    export let honeyBalance = 0;
    export let stroke = 0;

    const normalizedRadius = radius - stroke * 2;
    const circumference = normalizedRadius * 2 * Math.PI;

    let sdo = 0;
    let transSpeed = 0;

    const strokeDashoffset = () => {
        sdo = circumference - progress / 100 * circumference;
    }

    setTimeout(function(){ transSpeed = 15; }, 3000);

    $: progress, strokeDashoffset();

</script>


<svg height="{radius * 2}" width="{radius * 2}">
    <circle
        style="transition: stroke-dashoffset {transSpeed}s;"
        stroke="black"
        stroke-dasharray="{circumference} {circumference}"
        stroke-dashoffset="{ sdo }"
        stroke-width="{stroke}"
        fill="transparent"
        r="{normalizedRadius}"
        cx="{radius}"
        cy="{radius}"
    />
    {#if honeyBalance < 1}
        <text x="50%" y="54%" text-anchor="middle" class="font-bold" fill="black">{parseFloat(honeyBalance).toFixed(2)} HNY</text>
        {:else}
        <text x="50%" y="54%" text-anchor="middle" class="font-bold" fill="black">{honeyBalance} HNY</text>
    {/if}
</svg>

<style>
    circle {
        transform: rotate(-90deg);
        transform-origin: 50% 50%;
    }
</style>
  