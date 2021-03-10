<script>
  export let paginated = false;
  export let title = 'Data';
</script>

{#if paginated}
  <p>More results available, paginatined responses for {title} not yet implemented</p>
{/if}
