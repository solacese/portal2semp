<script>
  // Svelte Routes bug workaround
  export let location
</script>

<div style="width:100%">
<h1>Instructions</h1>

<p>Introduction</p>
<p>Portal 2 Semp reads Application Domains in the Event Portal and works out which Applications should consume which events.  For Applications that require events to be persisted, a queue is created. Topic subscriptions are added to the queue so that the right events are attracted to the queue ready for consumption<p>

<p>The end result is all the user has to do is select which application domain, which applications and which events.  Portal 2 Semp creates everything on the broker required to receive the events - all you have to do is connect your consumer to the queue!<p>

<h2>Next steps</h2>
<p>Click the "1. Get Application Domains" Navigation button to start entering details of Event Portal and selecting Application Domains and Applications</p>

<p>Then just follow the stages in the navigation bar one by one.</p>
</div>
