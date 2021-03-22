<script>
  export let title = "API logs";
  export let logString = "";

  export const apiGet = (method, description, url, options) => {
    logString += description + " -> " + method + ": " + url + "\n";
    return fetch(url, options);
  }

  const clearLog = () => {
    logString = "";
  }
</script>

<p>
<div style="width:100%;display:block">
<hr>
<h2>Logs: what was sent to the {title}</h2>
<textarea rows="6" cols="80" readonly="true" placeholder={title}>
{logString}
</textarea>
<button on:click={clearLog}>Clear log</button>
</div>
