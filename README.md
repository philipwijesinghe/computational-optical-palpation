# computational-optical-palpation
Toolbox for performing computational optical palpation

Published as:
Wijesinghe, P., Sampson, D. D., & Kennedy, B. F. (2017). Computational optical palpation: a finite-element approach to micro-scale tactile imaging using a compliant sensor. Journal of The Royal Society Interface, 14(128), 20160878.
http://dx.doi.org/10.1098/rsif.2016.0878

Abstract:
High-resolution tactile imaging, superior to the sense of touch, has potential for future biomedical applications such as robotic surgery. In this paper, we propose a tactile imaging method, termed computational optical palpation, based on measuring the change in thickness of a thin, compliant layer with optical coherence tomography and calculating tactile stress using finite-element analysis. We demonstrate our method on test targets and on freshly excised human breast fibroadenoma, demonstrating a resolution of up to 15–25 µm and a field of view of up to 7 mm. Our method is open source and readily adaptable to other imaging modalities, such as ultrasonography and confocal microscopy.

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

