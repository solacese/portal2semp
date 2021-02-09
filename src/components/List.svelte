<script>
  import { fade } from 'svelte/transition';

  export let promise;
  export let list;
  export let addFunc;
  export let displayFunc;
  export let removeFunc;
  export let hovering;
  export let description;

</script>

{#await promise}
<p>... Fetching Data, please wait...</p>
{:then}

<div style="float:left">
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

{#if hovering}
<div style="float:left">
<p transition:fade>Description: {@html description}</p>
</div>
{/if}

{:catch error}
<p>Error: ${error.message}</p>
{/await}
