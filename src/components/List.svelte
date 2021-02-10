<script>
  import { fade } from 'svelte/transition';

  export let promise;
  export let list;
  export let addFunc;
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
</style>

{#await promise}
<p>... Fetching Data, please wait...</p>
{:then}

<div style="float:{side}">

{#each list as element}
  <li
    class="select"
    on:click={() => addFunc(element)}
    on:mouseover = { () =>  displayFunc(element) }
    on:mouseout  = { () =>  removeFunc() }
    >
    {element.name}
  </li>
{/each}
</div>

{#if displayDescription == true}
  {#if hovering}
    <div style="float:left">
    <p transition:fade>Description: {@html description}</p>
    </div>
  {/if}
{/if}

{:catch error}
<p>Error: ${error.message}</p>
{/await}
