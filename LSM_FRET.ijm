/*************************************************************************\
 * Analysis of FRET data for ImageJ					 				    *
 * Written by Philippe Girard, Email: philippe.girard@ijm.fr		  	*
 * This macro is designed to analyze FRET data from confocal images		*
 \************************************************************************/




idlsm= getImageID();
run("Grays");
run("Clear Results");
run("Select None");

run("Properties...", "channels=1 slices="+nSlices+" frames=1 pixel_width=0.1317882 pixel_height=0.1317882 voxel_depth=1.0000000")

setTool("rectangle");
setSlice(1);
waitForUser("ROI","Sélectionner une région à analyser avec l'outil Rectangular");
run("Plot Z-axis Profile");
idZProfile= getImageID();
wait(1000);

//------- Dialog pour la sélection des images du mode spectrale
selectImage(idlsm);
run("Select None");
Dialog.create("Sélectionner les images de FRET");
Dialog.addSlider("Image mTFP1 :", 1, nSlices, 2);
Dialog.addSlider("Image EYFP :", 1, nSlices, 6);
Dialog.show;
idxmTFP= Dialog.getNumber;
idxEYFP= Dialog.getNumber;
selectImage(idZProfile);
close();

//------- Traitement de l'image mTFP
selectImage(idlsm);
setSlice(idxmTFP);
run("Duplicate...", " ");
rename("mTFP.tif");
idmTFP= getImageID();
run("32-bit");
setTool("rectangle");
run("Clear Results");
run("Select None");
waitForUser("mTFP1","Sélectionner une région du background avec l'outil Rectangular");
run("Measure");
bkgmTFP=getResult("Mean",0);
run("Select None");
run("Subtract...", "value="+ bkgmTFP);
//run("Threshold...");
setAutoThreshold("Default dark");
run("NaN Background");


//------- Traitement de l'image EYFP
selectImage(idlsm);
setSlice(idxEYFP);
run("Duplicate...", " ");
rename("EYFP.tif");
idEYFP= getImageID();
run("32-bit");
setTool("rectangle");
run("Select None");
waitForUser("EYFP","Sélectionner une région du background avec l'outil Rectangular");
run("Measure");
bkgEYFP=getResult("Mean",1);
run("Select None");
run("Subtract...", "value="+ bkgEYFP);
//run("Threshold...");
setAutoThreshold("Default dark");
run("NaN Background");

//------- Traitement de l'image FRET
//------- 1) création de l'image mTFP+EYFP
imageCalculator("Add create 32-bit", "EYFP.tif","mTFP.tif");
selectWindow("Result of EYFP.tif");
rename("mTFP+EYFP.tif");
//------- 2) création de l'image EYFP/(mTFP+EYFP)
imageCalculator("Divide create 32-bit", "EYFP.tif","mTFP+EYFP.tif");
selectWindow("Result of EYFP.tif");
rename("FRET.tif");
run("Multiply...", "value=100");
run("Enhance Contrast", "saturated=0.35");
run("Fire");


