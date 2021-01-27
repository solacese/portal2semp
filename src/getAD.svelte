<script>
  let name = 'world';
  let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1hYXNfcHJvZF8yMDIwMDMyNiIsInR5cCI6IkpXVCJ9.eyJvcmciOiJzZWFsbCIsIm9yZ1R5cGUiOiJFTlRFUlBSSVNFIiwic3ViIjoiNjd0cjh0a3VidCIsInBlcm1pc3Npb25zIjoiQUFBQUFJQUVBQUFBV3pnQUFBQUFBQUFBQUFBQUFBQUFBQUN3UUFNPSIsImFwaVRva2VuSWQiOiIxYTJudnNmMDZ3NWQiLCJpc3MiOiJTb2xhY2UgQ29ycG9yYXRpb24iLCJpYXQiOjE2MDgxMzkwNDd9.I9tX7C3vPgpjVo0rvra2-7J9eeSeYaDMA592BaQDmYU7V0vn9Zzij5hV-WgooTN49I6IhlZRCuXoIgLtN5fJQqs6dmf1luHh0piHeAsGGfQ-yuqB6m-hdTDe9hSXfrJW9QQZUZWbjPF4PBIJ5pmcAgsMEgW7OkzdMN2yW8M8R3WtY0HZENTQTvyuoZ1yOTAdDTGwgVt73eik2Eg34D8Q42Q_f0fJJUicIPdTuGZjyD5PK9-g8U32BQda13w-PtaiU7BAuZWA-Jds18huroATej_skkEP9yMlmg-F_WnETWBCaRUG28SkfUwdGt-TIYL5gZpUBmTZegKH1iMkVogVEA";
  let portalUrl = "https://solace.cloud/api/v1/eventPortal/";
  let applicationDomainSuffix = "applicationDomains";
  let promise;
  let selectedApps = [];
  let appDomains = [];
  function processApplicationDomains(data) {
    data.data.forEach(appObj => {
      let obj = { [appObj.name]: appObj.id};
      appDomains = [...appDomains, { name: appObj.name, id: appObj.id}];
    });
    console.log(appDomains);
    return data;
  }
  const handleClick = () => {
    let url = portalUrl + applicationDomainSuffix;
    console.log("Url: ", url);
    promise = fetch(
        url,
        {
          headers: {
            Authorization: token
          } 
        }
    ).then((x) => x.json())
     .then((y) => processApplicationDomains(y));
  };
</script>

<div>
<label for="url">Event Portal URL:</label>
<input bind:value={portalUrl}>

<button on:click="{handleClick}">
  Click to Load Data
</button>
</div>

{#await promise}
<!-- optionally show something while promise is pending -->
Getting data
{:then data}
<!-- promise was fulfilled -->
<div style="float:left">
{#each appDomains as app}
<label>
  <input type=checkbox bind:group={selectedApps} value={app.name}> {app.name}
</label>
{/each}
</div>

{#if selectedApps.length > 0}
  <div style="float:right">
  {#each selectedApps as showApp}
    <p>{showApp}/<p>
  {/each}
  </div>
{/if}
>
{:catch error}
<!-- optionally show something while promise was rejected -->
<p>Error: ${error.message}</p>
{/await}
