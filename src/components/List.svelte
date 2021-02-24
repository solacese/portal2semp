<script>
  import { fade } from 'svelte/transition';

  export let promise;
  export let list;
  export let clickFunc;
  export let side;
  export let displayDescription;
  export let title;

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
  top: -5px;
  left: 95%;
}

.select .tooltiptext_small {
  visibility: hidden;
  width: 150px;
  background-color: #e6fff7;
  color: #666666;
  text-align: left;
  padding: 5px 0;
  border-radius: 6px;
  
  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
  top: -5px;
  left: 95%;
}

/* Show the tooltip text when you mouse over the tooltip container */
.select:hover .tooltiptext {
  visibility: visible;
}
.select:hover .tooltiptext_small {
  visibility: visible;
}

.myborder {
  margin: 5px;
}
</style>

{#await promise}
<p>... Fetching Data, please wait...</p>
{:then}

<div class="myborder" style="float:{side}">
<h2>{@html title}</h2>

{#each list as element}
  <li
    class="select"
    on:click={ () => clickFunc(element) }
    >
    {element.name}
    {#if displayDescription == true}
      {#if element.description === ""}
        <p class="tooltiptext_small" transition:fade>No description</p>
      {:else}
        <p class="tooltiptext" transition:fade>Description: {@html element.description}</p>
      {/if}
    {/if}
  </li>
{/each}
</div>

{:catch error}
<p>Error: ${error.message}</p>
{/await}
