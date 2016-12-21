# computational-optical-palpation
Toolbox for performing computational optical palpation

<i>Scheduled for release alongside journal publication (Computational optical palpation: A finite-element approach to micro-scale tactile imaging using a compliant sensor) - under review</i>

<h2>Requirements</h2>
<ul>
<li>matlab (tested with 2014a), including 3rd party toolboxes:</li>
<ul>
	<li>gridfit</li>
	<li>Inpaint_nans</li>
</ul>
<li>python (tested with 2.7 and 3.5)</li>
<li>Abaqus (tested with 6.13)</li>
</ul>

<h3>main_cop_explicit</h3>
<emph>function</emph>
<p>main function, generates input files, oversees abaqus FEA, and parses outputs</p>

<p>Usage is outlined in the function, and demonstrated in:</p>
<emph>example_run_cop.m</emph>

