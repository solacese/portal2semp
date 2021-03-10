<script>
  import { fade } from 'svelte/transition';

  export let promise;
  export let list = ["First Element", "Second Element"];
  export let clickFunc = () => { 
     console.log("List: ", title);
    }
  export let side = 'left';
  export let displayDescription = true;
  export let title = 'A List';
  export let displayTitle = true;
  export let context = "";

</script>

{#await promise}
<p>... Fetching Data, please wait...</p>
{:then}

<div class="myborder" style="float:{side}">
{#if displayTitle}
  <h2>{@html title}</h2>
{/if}

{#each list as element}
  <li
    class="select"
    on:click={ () => clickFunc(element, context) }
    >
    <div class="tooltip">
    {element.name}
    {#if displayDescription == true}
      {#if element.description === ""}
        <p class="tooltiptext" transition:fade>No description</p>
      {:else}
        <p class="tooltiptext" transition:fade>Description: {@html element.description}</p>
      {/if}
    {/if}
    </div>
  </li>
{/each}
</div>

{:catch error}
<p>Error: ${error.message}</p>
{/await}
