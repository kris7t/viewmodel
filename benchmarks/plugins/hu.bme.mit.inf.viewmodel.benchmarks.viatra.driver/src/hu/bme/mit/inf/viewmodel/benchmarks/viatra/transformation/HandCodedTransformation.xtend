/********************************************************************************
 * Copyright (c) 2018 Contributors to the ViewModel project
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * SPDX-License-Identifier: EPL-1.0
 ********************************************************************************/
package hu.bme.mit.inf.viewmodel.benchmarks.viatra.transformation

import hu.bme.mit.inf.viewmodel.benchmarks.models.railway.RailwayContainer
import java.util.UUID
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.api.IQueryGroup
import org.eclipse.viatra.query.runtime.api.ViatraQueryEngine
import org.eclipse.viatra.query.runtime.base.api.BaseIndexOptions
import org.eclipse.viatra.query.runtime.base.api.IndexingLevel
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.eclipse.viatra.transformation.evm.api.Scheduler.ISchedulerFactory
import org.eclipse.viatra.transformation.evm.api.resolver.ConflictResolver
import org.eclipse.viatra.transformation.evm.specific.resolver.ArbitraryOrderConflictResolver
import org.eclipse.viatra.transformation.runtime.emf.rules.EventDrivenTransformationRuleGroup
import org.eclipse.viatra.transformation.runtime.emf.rules.eventdriven.EventDrivenTransformationRuleFactory
import org.eclipse.viatra.transformation.runtime.emf.transformation.eventdriven.EventDrivenTransformation
import org.eclipse.xtend.lib.annotations.Accessors

abstract class HandCodedTransformation {
	protected extension val EventDrivenTransformationRuleFactory = new EventDrivenTransformationRuleFactory

	val RailwayContainer railwayContainer
	protected val ResourceSet resourceSet
	@Accessors protected val Resource targetResource

	@Accessors(PUBLIC_GETTER) AdvancedViatraQueryEngine queryEngine
	EventDrivenTransformation transformation

	new(RailwayContainer railwayContainer, ResourceSet resourceSet) {
		this.railwayContainer = railwayContainer
		this.resourceSet = resourceSet
		val traceResource = getUniqueResource("trace")
		traceResource.contents += createTraceModel(railwayContainer)
		targetResource = getUniqueResource("target")
	}

	private def getUniqueResource(String prefix) {
		resourceSet.createResource(URI.createFileURI(prefix + "-" + UUID.randomUUID.toString + ".xmi"))
	}

	protected abstract def EObject createTraceModel(RailwayContainer railwayContainer)

	abstract def int getTraceLinkCount()

	def void createQueryEngine() {
		val baseIndexOptions = new BaseIndexOptions().withWildcardLevel(IndexingLevel.FULL)
		queryEngine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(resourceSet, baseIndexOptions))
		queryGroup.prepare(queryEngine)
		createMatchers(queryEngine)
	}

	protected abstract def IQueryGroup getQueryGroup()

	protected abstract def void createMatchers(ViatraQueryEngine queryEngine)

	protected abstract def void createRules()

	protected abstract def EventDrivenTransformationRuleGroup getTransformationRuleGroup()

	protected def ConflictResolver getConflictResolver() {
		new ArbitraryOrderConflictResolver
	}

	def void createTransformation(ISchedulerFactory schedulerFactory) {
		createRules()
		val builder = EventDrivenTransformation.forEngine(queryEngine).addRules(transformationRuleGroup)
		builder.conflictResolver = conflictResolver
		if (schedulerFactory !== null) {
			builder.schedulerFactory = schedulerFactory
		}
		transformation = builder.build
	}

	def void startUnscheduledExecution() {
		transformation.executionSchema.startUnscheduledExecution
	}

	def dispose() {
		if (transformation !== null) {
			// Also disposes the query engine.
			transformation.dispose
		} else if (queryEngine !== null) {
			queryEngine.dispose
		}
	}
}
