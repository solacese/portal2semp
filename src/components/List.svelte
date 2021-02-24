<script>
  import { fade } from 'svelte/transition';

  export let promise;
  export let list;
  export let clickFunc;
  export let displayFunc;
  export let removeFunc;
  export let hovering;
  export let description;
  export let side;
  export let displayDescription;

</script>

<style>
li.select {
  cursor: pointer;
  position: relative;
  left: 0;
  background-color: #e6ffe6;
  margin: .5em;
  padding: .3em 0;
  height: 1.0em;
  border-radius: 4px;
}
li.select:hover {
  color: #607D8B;
  background-color: #99ff99;
  left: .1em;
}

.select {
}

/* Tooltip text */
.select .tooltiptext {
  visibility: hidden;
  width: 600px;
  background-color: #e6fff7;
  color: #666666;
  text-align: left;
  padding: 5px 0;
  border-radius: 6px;
 
  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
}

/* Show the tooltip text when you mouse over the tooltip container */
.select:hover .tooltiptext {
  visibility: visible;
}
</style>

{#await promise}
<p>... Fetching Data, please wait...</p>
{:then}

<div style="float:{side}">

{#each list as element}
  <li
    class="select"
    on:click={ () => clickFunc(element) }
    on:mouseover = { () =>  displayFunc(element) }
    on:mouseout  = { () =>  removeFunc() }
    >
    {element.name}
    {#if displayDescription == true}
      <p class="tooltiptext" transition:fade>Description: {@html description}</p>
    {/if}
  </li>
{/each}
</div>

{:catch error}
<p>Error: ${error.message}</p>
{/await}
