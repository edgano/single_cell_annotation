include { merge } from "${projectDir}/modules/merge/merge.nf"
include { plot_merge } from "${projectDir}/modules/merge/plot_merge.nf"

workflow merge_workflow {
    take:
    to_merge
    main:
    //to_merge
//	.map {biopsy_type, sample, sample___h5ad -> tuple(biopsy_type, sample___h5ad)}
//	.groupTuple()
//	.view()	    

    merge(to_merge
	  .map {biopsy_type, sample, sample___h5ad -> tuple(biopsy_type, sample___h5ad)}
	  .groupTuple(),
    	  Channel.fromPath(params.samples_metainfo_tsv, checkIfExists: true).collect(),
    	  Channel.fromPath(params.merge.filter_params, checkIfExists: true).collect())
    
    plot_merge(merge.out.to_plot)
    
    emit:
    merged_h5ad = merge.out.biopsy_type_h5ad
    
}
