<script>
  import { Link } from "svelte-routing";
  import { storeAD } from '../stores.js';
  let selectedDomains = [];

  const unsubscribe = storeAD.subscribe(value => {
    selectedDomains = value;
  });
</script>

<p>Stage 2: Select you Applications</p>

Each Application Domain in Event Portal can contain multiple Applications.  In the list below are all those Applications we've indentified as needing events persisted for them for later consumption.<p>

<p>Simply select those applications you'd like to deploy and continue to Stage 3.</p>
<hr>

{#if selectedDomains.length > 0 }
  {#if selectedDomains.length === 1}
    <h2>Selected Domain</h2>
  {:else}
    <h2>Selected Domains</h2>
  {/if}
  {#each selectedDomains as showDomain}
    <li>{showDomain.name}</li>
  {/each}

{:else}
  <p><strong>You haven't selected any Application Domains!</strong></p>

<p>Please go back to the <Link to="getAD">previous step</Link> and pick at least one</p>
{/if}

