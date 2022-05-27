<script>
  import { Router, Route } from "svelte-routing";
  import NavLink from "./components/NavLink.svelte";
  import Instructions from "./routes/Instructions.svelte";
  import GetAD from './routes/getAD.svelte';
  import GetApps from './routes/getApps.svelte';
  import DrawArt from './routes/drawArt.svelte';
  import Semp from './routes/semp.svelte';
  export let url = "";
  document.title = "Event Portal 2 Semp";
</script>

<style>
div {
  margin: 0 0 2em 0;
  list-style-type: none;
  padding: 0;
}
</style>

<header>
<title>Portal 2 Semp</title>
</header>

<Router url="{url}">
<nav>
<h1> Portal 2 Semp </h1>
  <NavLink to="/">
    <img src="./images/instructions.png" 
			   style="height:25px" 
			   alt=" ">
     Instructions</NavLink>
  <NavLink to="getAD">
    <img src="./images/ad.png" 
			   style="height:25px" 
			   alt=" ">
    Application Domains</NavLink>
  <NavLink to="getApps">
    <img src="./images/app.png" 
			   style="height:25px" 
			   alt=" ">
    Applications</NavLink>
  <NavLink to="drawArt">
    <img src="./images/yes.png" 
			   style="height:25px" 
			   alt=" ">
    Check deployment</NavLink>
  <NavLink to="semp">
    <img src="./images/deploy.png" 
			   style="height:25px" 
			   alt=" ">
    Deploy</NavLink>
<hr>
</nav>
<div>
  <Route path="/" component="{Instructions}" />
  <Route path="getAD" component="{GetAD}" />
  <Route path="getApps" component="{GetApps}" />
  <Route path="drawArt" component="{DrawArt}" />
  <Route path="semp" component="{Semp}" />
</div>
</Router>
