<script>
  import { Router, Route } from "svelte-routing";
  import NavLink from "./components/NavLink.svelte";
  import Instructions from "./routes/Instructions.svelte";
  import GetAD from './routes/getAD.svelte';
  import GetApps from './routes/getApps.svelte';
  import GetEvents from './routes/getEvents.svelte';
  import DrawArt from './routes/drawArt.svelte';
  import Semp from './routes/semp.svelte';
  export let url = "";
</script>

<style>
div {
  margin: 0 0 2em 0;
  list-style-type: none;
  padding: 0;
}
li.plain {
  background-color: #ffffff;
}
li.plain:hover {
  color: #000000;
  background-color: #ffffff;
}
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
label.select {
  text-align: right;
  clear: both;
  float: left;
  margin-right: 15px;
}
input {
  float: right;
}
</style>

<header>
<title>Portal 2 Semp</title>
</header>

<Router url="{url}">
<nav>
<h1> Portal 2 Semp </h1>
  <NavLink to="/">Instructions</NavLink>
  <NavLink to="getAD">1. Application Domains</NavLink>
  <NavLink to="getApps">2. Applications</NavLink>
  <NavLink to="getEvents">3. Events</NavLink>
  <NavLink to="drawArt">4. Check deployment</NavLink>
  <NavLink to="semp">5. Deploy</NavLink>
<hr>
</nav>
<div>
  <Route path="/" component="{Instructions}" />
  <Route path="getAD" component="{GetAD}" />
  <Route path="getApps" component="{GetApps}" />
  <Route path="getEvents" component="{GetEvents}" />
  <Route path="drawArt" component="{DrawArt}" />
  <Route path="semp" component="{Semp}" />
</div>
</Router>
