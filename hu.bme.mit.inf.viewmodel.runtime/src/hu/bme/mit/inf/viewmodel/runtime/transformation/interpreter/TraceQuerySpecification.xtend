package hu.bme.mit.inf.viewmodel.runtime.transformation.interpreter

import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.viatra.query.runtime.api.impl.BaseGeneratedEMFQuerySpecificationWithGenericMatcher

class TraceQuerySpecification extends BaseGeneratedEMFQuerySpecificationWithGenericMatcher {
	
	new(String traceName, List<String> argumentNames, EClass traceClass) {
		super(new TracePQuery(traceName, argumentNames, traceClass))
	}
}