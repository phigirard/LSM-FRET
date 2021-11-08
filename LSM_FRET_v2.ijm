/*************************************************************************\
 * Analysis of FRET data for ImageJ					 				    *
 * Written by Philippe Girard, Email: philippe.girard@ijm.fr		  	*
 * This macro is designed to analyze FRET data from confocal images		*
 \************************************************************************/




idlsm= getImageID();
slices = nSlices
run("Properties...", "channels=1 slices="+slices+" frames=1 pixel_width=1.0000000 pixel_height=1.0000000 voxel_depth=1.0000000")

run("Grays");
run("Clear Results");
run("Select None");

selectImage(idlsm);
setTool("rectangle");
setSlice(1);
waitForUser("ROI","Select a ROI with the rectangle tool");
run("Plot Z-axis Profile");
idZProfile= getImageID();
wait(1000);

//------- Dialog for FRET image selection
selectImage(idZProfile);
Dialog.create("Select Donnor/Acceptor images");
Dialog.addSlider("Donnor Image:", 1, slices, 1);
Dialog.addSlider("Acceptor Image :", 1, slices, 6);
Dialog.show;
idxDonnor= Dialog.getNumber;
idxAcceptor= Dialog.getNumber;
selectImage(idZProfile);
close();

//------- Process Donnor image
selectImage(idlsm);
run("Select None");
setSlice(idxDonnor);
run("Duplicate...", " ");
rename("Donnor.tif");
idDonnor= getImageID();
run("32-bit");
setTool("rectangle");
run("Clear Results");
run("Select None");
waitForUser("Background substraction","Select a ROI with the Rectangle tool for background substraction");
roiManager("Add");
run("Measure");
bkgDonnor=getResult("Mean",0);
run("Select None");
run("Subtract...", "value="+ bkgDonnor);
setAutoThreshold("Otsu dark");
run("NaN Background");


//------- Process Acceptor image
selectImage(idlsm);
setSlice(idxAcceptor);
run("Duplicate...", " ");
rename("Acceptor.tif");
idAcceptor= getImageID();
run("32-bit");
run("Select None");
roiManager("Select", 0);
run("Measure");
bkgAcceptor=getResult("Mean",1);
run("Select None");
run("Subtract...", "value="+ bkgAcceptor);
setAutoThreshold("Otsu dark");
run("NaN Background");

//-------  FRET index 
//------- 1) Acceptor+Donnor image
imageCalculator("Add create 32-bit", "Acceptor.tif","Donnor.tif");
selectWindow("Result of Acceptor.tif");
rename("Donnor+Acceptor.tif");
//------- 2) FRET index =  Acceptor/(Acceptor+Donnor)
imageCalculator("Divide create 32-bit", "Acceptor.tif","Donnor+Acceptor.tif");
selectWindow("Result of Acceptor.tif");
rename("FRET.tif");
run("Multiply...", "value=100");
resetMinAndMax();
run("Fire");
selectWindow("Donnor+Acceptor.tif");
close();


