<script>
  import { Router, Route } from "svelte-routing";
  import NavLink from "./components/NavLink.svelte";
  import Instructions from "./routes/Instructions.svelte";
  import GetAD from './routes/getAD.svelte';
  import GetApps from './routes/getApps.svelte';
  export let url = "";
</script>

<header>
<title>Portal 2 Semp</title>
</header>

<Router url="{url}">
<nav>
<h1> Portal 2 Semp </h1>
  <NavLink to="/">Instructions</NavLink>
  <NavLink to="getAD">1. Application Domains</NavLink>
  <NavLink to="getApps">2. Applications</NavLink>
<hr>
</nav>
<div>
  <Route path="/" component="{Instructions}" />
  <Route path="getAD" component="{GetAD}" />
  <Route path="getApps" component="{GetApps}" />
</div>
</Router>
