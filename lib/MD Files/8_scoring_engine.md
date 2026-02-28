# SmartERP Engineering Quality Scoring Engine

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Purpose:** Define how engineering quality is measured and scored

---

## 1. Scoring Engine Overview

### 1.1 Purpose

The Engineering Quality Scoring Engine provides a quantitative framework to measure, track, and improve the technical quality of the SmartERP codebase. It establishes objective metrics across multiple quality dimensions and provides actionable feedback for continuous improvement.

### 1.2 Scoring Philosophy

| Principle | Implementation |
|-----------|---------------|
| **Objectivity** | Metrics based on measurable code characteristics |
| **Automation** | Scores computed via automated tools and scripts |
| **Actionability** | Each metric includes improvement guidelines |
| **Balance** | No single metric dominates the total score |
| **Progressive** | Tracks improvement over time |

### 1.3 Quality Dimensions

| Dimension | Weight | Max Score | Focus Area |
|-----------|--------|-----------|------------|
| **Code Quality** | 25% | 25 | Maintainability, readability, structure |
| **Performance** | 20% | 20 | Speed, efficiency, resource usage |
| **Security** | 20% | 20 | Vulnerabilities, best practices |
| **Maintainability** | 15% | 15 | Testability, coupling, complexity |
| **Scalability** | 10% | 10 | Architecture, extensibility |
| **Documentation** | 10% | 10 | Code docs, external docs |
| **Total** | **100%** | **100** | - |

---

## 2. Code Quality Score (25 points)

### 2.1 Metrics Breakdown

| Metric | Points | Measurement Tool | Target |
|--------|--------|------------------|--------|
| Static Analysis Score | 8 | `dart analyze` | Zero warnings/errors |
| Code Style Compliance | 5 | `dart format` + `flutter_lints` | 100% compliant |
| Cyclomatic Complexity | 5 | Custom analyzer | < 10 per function |
| Code Duplication | 4 | `jscpd` | < 3% duplication |
| Naming Conventions | 3 | Custom rules | 100% compliant |

### 2.2 Scoring Formulas

#### Static Analysis Score (8 points)

```dart
// Formula: 8 - (error_count * 0.5) - (warning_count * 0.1)
// Minimum: 0, Maximum: 8

int calculateStaticAnalysisScore(int errors, int warnings) {
  double score = 8.0 - (errors * 0.5) - (warnings * 0.1);
  return score.clamp(0, 8).toInt();
}

// Grading Scale:
// 8 points: 0 errors, 0-5 warnings
// 7 points: 0 errors, 6-15 warnings
// 6 points: 0 errors, 16-30 warnings
// 5 points: 1-2 errors, any warnings
// < 5 points: > 2 errors
```

#### Code Style Compliance (5 points)

```dart
// Formula: 5 * (compliant_lines / total_lines)
// Check: dart format --set-exit-if-changed

double calculateStyleCompliance(int compliantLines, int totalLines) {
  return 5.0 * (compliantLines / totalLines);
}

// Grading Scale:
// 5 points: 100% formatted
// 4 points: 95-99% formatted
// 3 points: 90-94% formatted
// 2 points: 80-89% formatted
// 1 point: 70-79% formatted
// 0 points: < 70% formatted
```

#### Cyclomatic Complexity Score (5 points)

```dart
// Formula based on complexity distribution

class ComplexityScoreCalculator {
  static int calculateScore(Map<String, int> functionComplexity) {
    int lowComplexity = 0;  // 1-5
    int mediumComplexity = 0; // 6-10
    int highComplexity = 0; // 11-20
    int veryHighComplexity = 0; // > 20
    
    for (final complexity in functionComplexity.values) {
      if (complexity <= 5) lowComplexity++;
      else if (complexity <= 10) mediumComplexity++;
      else if (complexity <= 20) highComplexity++;
      else veryHighComplexity++;
    }
    
    int total = functionComplexity.length;
    
    // Scoring
    if (highComplexity == 0 && veryHighComplexity == 0) return 5;
    if (veryHighComplexity == 0 && highComplexity < total * 0.1) return 4;
    if (veryHighComplexity < total * 0.05) return 3;
    if (veryHighComplexity < total * 0.1) return 2;
    return 1;
  }
}

// Thresholds per function:
// Excellent: ≤ 5 (linear paths)
// Good: 6-10 (some branching)
// Acceptable: 11-20 (complex logic)
// Poor: > 20 (refactor required)
```

#### Code Duplication Score (4 points)

```dart
// Formula: 4 - (duplication_percentage * 0.4)

int calculateDuplicationScore(double duplicationPercentage) {
  double score = 4.0 - (duplicationPercentage * 0.4);
  return score.clamp(0, 4).toInt();
}

// Grading Scale:
// 4 points: < 1% duplication
// 3 points: 1-3% duplication
// 2 points: 3-5% duplication
// 1 point: 5-8% duplication
// 0 points: > 8% duplication
```


#### Naming Conventions Score (3 points)

| Convention | Weight | Check |
|------------|--------|-------|
| Classes: PascalCase | 20% | `^[A-Z][a-zA-Z0-9]*$` |
| Functions: camelCase | 25% | `^[a-z][a-zA-Z0-9]*$` |
| Constants: lowerCamel or UPPER_SNAKE | 15% | Pattern match |
| Files: snake_case.dart | 20% | `^[a-z_]+\.dart$` |
| Private: _prefix | 20% | Leading underscore |

```dart
int calculateNamingScore(
  int totalIdentifiers,
  Map<String, int> conventionViolations,
) {
  double totalViolations = conventionViolations.values.reduce((a, b) => a + b);
  double compliance = 1.0 - (totalViolations / totalIdentifiers);
  return (3.0 * compliance).toInt();
}
```

---

## 3. Performance Score (20 points)

### 3.1 Metrics Breakdown

| Metric | Points | Measurement | Target |
|--------|--------|-------------|--------|
| Build Performance | 6 | Build time profiling | < 5 min clean build |
| App Launch Time | 5 | Flutter performance tests | < 3 sec cold start |
| Runtime Performance | 5 | Frame times, jank | 60 FPS, 0 jank |
| Memory Efficiency | 4 | Memory profiling | < 150 MB baseline |

### 3.2 Scoring Formulas

#### Build Performance Score (6 points)

```dart
// Formula based on build times

int calculateBuildScore(Duration cleanBuildTime) {
  int seconds = cleanBuildTime.inSeconds;
  
  if (seconds < 120) return 6;        // < 2 min: Excellent
  if (seconds < 180) return 5;        // < 3 min: Good
  if (seconds < 300) return 4;        // < 5 min: Acceptable
  if (seconds < 420) return 3;        // < 7 min: Slow
  if (seconds < 600) return 2;        // < 10 min: Poor
  if (seconds < 900) return 1;        // < 15 min: Critical
  return 0;                           // > 15 min: Unacceptable
}
```

#### App Launch Score (5 points)

```dart
// Measured via Flutter Driver or native profiling

int calculateLaunchScore({
  required Duration coldStartTime,
  required Duration warmStartTime,
}) {
  int score = 0;
  
  // Cold start (70% weight)
  if (coldStartTime.inMilliseconds < 1500) score += 4;
  else if (coldStartTime.inMilliseconds < 3000) score += 3;
  else if (coldStartTime.inMilliseconds < 5000) score += 2;
  else if (coldStartTime.inMilliseconds < 8000) score += 1;
  
  // Warm start (30% weight)
  if (warmStartTime.inMilliseconds < 500) score += 1;
  else if (warmStartTime.inMilliseconds < 1000) score += 1;
  
  return score.clamp(0, 5);
}
```

#### Runtime Performance Score (5 points)

```dart
// Frame rendering metrics

int calculateRuntimeScore({
  required double averageFrameTime, // milliseconds
  required int missedFrames, // frames > 16.6ms
  required double p95FrameTime, // 95th percentile
}) {
  int score = 5;
  
  // Deduct for missed frames
  if (missedFrames > 100) score -= 2;
  else if (missedFrames > 50) score -= 1;
  
  // Deduct for slow average
  if (averageFrameTime > 16.6) score -= 1;
  
  // Deduct for bad p95
  if (p95FrameTime > 33.3) score -= 1;
  
  return score.clamp(0, 5);
}

// Targets:
// Average frame time: ≤ 16.6ms (60 FPS)
// Missed frames (jank): < 10 per session
// P95 frame time: ≤ 33.3ms
```

#### Memory Efficiency Score (4 points)

```dart
int calculateMemoryScore({
  required int baselineMemoryMB, // After app launch
  required int peakMemoryMB, // During heavy usage
  required int leakSuspects, // Potential leaks detected
}) {
  int score = 4;
  
  // Baseline memory
  if (baselineMemoryMB > 200) score -= 1;
  if (baselineMemoryMB > 300) score -= 1;
  
  // Peak memory
  if (peakMemoryMB > 400) score -= 1;
  
  // Leak suspects
  if (leakSuspects > 10) score -= 1;
  else if (leakSuspects > 5) score -= 1;
  
  return score.clamp(0, 4);
}

// Targets:
// Baseline: < 150 MB
// Peak: < 300 MB
// Leaks: 0 detected
```

---

## 4. Security Score (20 points)

### 4.1 Metrics Breakdown

| Metric | Points | Measurement | Target |
|--------|--------|-------------|--------|
| Dependency Vulnerabilities | 6 | `flutter pub audit` | 0 high/critical |
| Static Security Analysis | 5 | Custom security lint | 0 findings |
| Secure Coding Practices | 5 | Code review checklist | 100% compliance |
| Data Protection | 4 | Encryption audit | Full coverage |

### 4.2 Scoring Formulas

#### Dependency Vulnerabilities Score (6 points)

```dart
int calculateDependencyScore({
  required int criticalVulns,
  required int highVulns,
  required int mediumVulns,
  required int lowVulns,
}) {
  int score = 6;
  
  // Critical: -3 each
  score -= criticalVulns * 3;
  
  // High: -2 each
  score -= highVulns * 2;
  
  // Medium: -1 each (max -2)
  score -= (mediumVulns * 1).clamp(0, 2);
  
  // Low: -0.5 each (max -1)
  score -= (lowVulns * 0.5).ceil().clamp(0, 1);
  
  return score.clamp(0, 6);
}

// Targets:
// Critical: 0
// High: 0
// Medium: < 3
// Low: < 5
```

#### Static Security Analysis Score (5 points)

| Vulnerability Type | Severity | Points if Present |
|-------------------|----------|-------------------|
| Hardcoded credentials | Critical | -5 |
| Insecure storage | High | -3 |
| Weak cryptography | High | -3 |
| Logged sensitive data | Medium | -2 |
| Missing input validation | Medium | -1 |
| Insecure network config | Medium | -2 |

```dart
int calculateStaticSecurityScore(List<SecurityFinding> findings) {
  int score = 5;
  
  for (final finding in findings) {
    switch (finding.severity) {
      case Severity.critical:
        score -= 5;
        break;
      case Severity.high:
        score -= 3;
        break;
      case Severity.medium:
        score -= 1;
        break;
      case Severity.low:
        score -= 0;
        break;
    }
  }
  
  return score.clamp(0, 5);
}
```

#### Secure Coding Practices Score (5 points)

| Practice | Weight | Verification |
|----------|--------|--------------|
| Input validation | 20% | All user inputs validated |
| Output encoding | 15% | No raw output in UI |
| Error handling | 20% | No sensitive data in errors |
| Authentication checks | 25% | All routes protected |
| Data minimization | 20% | Only necessary data stored |

```dart
int calculateSecureCodingScore({
  required double inputValidationCoverage,
  required double outputEncodingCoverage,
  required double errorHandlingCoverage,
  required double authCheckCoverage,
  required double dataMinimizationScore,
}) {
  double weighted = 
    (inputValidationCoverage * 0.20) +
    (outputEncodingCoverage * 0.15) +
    (errorHandlingCoverage * 0.20) +
    (authCheckCoverage * 0.25) +
    (dataMinimizationScore * 0.20);
  
  return (5.0 * weighted).round();
}
```

#### Data Protection Score (4 points)

| Protection | Points | Requirement |
|------------|--------|-------------|
| TLS in transit | 1 | HTTPS only |
| Encrypted at rest | 1 | Sensitive data encrypted |
| Secure storage | 1 | Tokens in secure storage |
| Access controls | 1 | Firestore rules enforced |

```dart
int calculateDataProtectionScore({
  required bool tlsEnabled,
  required bool encryptionAtRest,
  required bool secureStorageUsed,
  required bool firestoreRulesEnforced,
}) {
  int score = 0;
  if (tlsEnabled) score += 1;
  if (encryptionAtRest) score += 1;
  if (secureStorageUsed) score += 1;
  if (firestoreRulesEnforced) score += 1;
  return score;
}
```

---

## 5. Maintainability Score (15 points)

### 5.1 Metrics Breakdown

| Metric | Points | Measurement | Target |
|--------|--------|-------------|--------|
| Test Coverage | 5 | `flutter test --coverage` | > 80% |
| Code Organization | 4 | Architecture review | Clean architecture |
| Coupling/Cohesion | 3 | Import analysis | Low coupling |
| Documentation Coverage | 3 | Doc comment analysis | > 60% public APIs |

### 5.2 Scoring Formulas

#### Test Coverage Score (5 points)

```dart
int calculateTestCoverageScore(double coveragePercentage) {
  if (coveragePercentage >= 90) return 5;
  if (coveragePercentage >= 80) return 4;
  if (coveragePercentage >= 70) return 3;
  if (coveragePercentage >= 60) return 2;
  if (coveragePercentage >= 50) return 1;
  return 0;
}

// Coverage targets:
// 5 points: ≥ 90%
// 4 points: 80-89%
// 3 points: 70-79%
// 2 points: 60-69%
// 1 point: 50-59%
// 0 points: < 50%
```

#### Code Organization Score (4 points)

| Aspect | Weight | Criteria |
|--------|--------|----------|
| Layer separation | 25% | No layer violations |
| Feature modularity | 25% | Features isolated |
| Dependency direction | 25% | Dependencies flow correctly |
| Single Responsibility | 25% | Classes have clear purpose |

```dart
int calculateOrganizationScore({
  required int layerViolations,
  required int featureCouplingIssues,
  required int wrongDirectionImports,
  required int srpViolations,
}) {
  int score = 4;
  
  if (layerViolations > 5) score -= 1;
  if (layerViolations > 10) score -= 1;
  
  if (featureCouplingIssues > 5) score -= 1;
  
  if (wrongDirectionImports > 10) score -= 1;
  
  if (srpViolations > 10) score -= 1;
  
  return score.clamp(0, 4);
}
```

#### Coupling/Cohesion Score (3 points)

```dart
int calculateCouplingScore({
  required double averageFanIn,    // Incoming dependencies
  required double averageFanOut,   // Outgoing dependencies
  required int circularDependencyCount,
}) {
  int score = 3;
  
  // High fan-out indicates high coupling
  if (averageFanOut > 10) score -= 1;
  if (averageFanOut > 20) score -= 1;
  
  // Circular dependencies
  if (circularDependencyCount > 0) score -= 1;
  if (circularDependencyCount > 5) score -= 1;
  
  return score.clamp(0, 3);
}

// Targets:
// Average fan-out: < 10 per file
// Circular dependencies: 0
```

#### Documentation Coverage Score (3 points)

```dart
int calculateDocumentationScore({
  required double publicApiDocCoverage, // % of public APIs with docs
  required bool readmeExists,
  required bool architectureDocExists,
  required bool apiDocExists,
}) {
  int score = 0;
  
  // API documentation
  if (publicApiDocCoverage >= 80) score += 2;
  else if (publicApiDocCoverage >= 60) score += 1;
  else if (publicApiDocCoverage >= 40) score += 0;
  
  // Project documentation
  if (readmeExists) score += 0;
  if (architectureDocExists) score += 0;
  if (apiDocExists) score += 1;
  
  return score.clamp(0, 3);
}
```

---

## 6. Scalability Score (10 points)

### 6.1 Metrics Breakdown

| Metric | Points | Assessment | Target |
|--------|--------|------------|--------|
| Architecture Extensibility | 4 | Design review | Plugin architecture |
| Performance Scaling | 3 | Load testing | Handles growth |
| Database Efficiency | 3 | Query analysis | Efficient queries |

### 6.2 Scoring Formulas

#### Architecture Extensibility Score (4 points)

| Criterion | Weight | Target |
|-----------|--------|--------|
| Feature isolation | 30% | Features independent |
| Repository pattern | 25% | Data layer abstracted |
| Dependency injection | 25% | Proper DI usage |
| Configuration externalized | 20% | No hardcoded values |

```dart
int calculateExtensibilityScore({
  required int featureIsolationScore, // 0-10
  required bool repositoryPatternUsed,
  required bool diFrameworkUsed,
  required double configExternalization, // % of config externalized
}) {
  double score = 0;
  
  score += (featureIsolationScore / 10) * 1.2; // Max 1.2 (30% of 4)
  if (repositoryPatternUsed) score += 1.0; // 25% of 4
  if (diFrameworkUsed) score += 1.0; // 25% of 4
  score += (configExternalization / 100) * 0.8; // Max 0.8 (20% of 4)
  
  return score.round().clamp(0, 4);
}
```

#### Performance Scaling Score (3 points)

```dart
int calculatePerformanceScaling({
  required bool paginationImplemented,
  required bool lazyLoadingUsed,
  required bool cachingStrategyImplemented,
  required int listRenderingOptimizationScore, // 0-10
}) {
  int score = 0;
  
  if (paginationImplemented) score += 1;
  if (lazyLoadingUsed) score += 0;
  if (cachingStrategyImplemented) score += 1;
  score += (listRenderingOptimizationScore / 10).round();
  
  return score.clamp(0, 3);
}
```

#### Database Efficiency Score (3 points)

| Metric | Target | Points |
|--------|--------|--------|
| N+1 queries | 0 | 1 |
| Indexed queries | > 90% | 1 |
| Query complexity | Simple only | 1 |

```dart
int calculateDatabaseEfficiency({
  required int nPlusOneQueryCount,
  required double indexedQueryPercentage,
  required int complexQueryCount,
}) {
  int score = 3;
  
  if (nPlusOneQueryCount > 0) score -= 1;
  if (nPlusOneQueryCount > 5) score -= 1;
  
  if (indexedQueryPercentage < 80) score -= 1;
  if (indexedQueryPercentage < 50) score -= 1;
  
  if (complexQueryCount > 5) score -= 1;
  
  return score.clamp(0, 3);
}
```

---

## 7. Documentation Score (10 points)

### 7.1 Metrics Breakdown

| Metric | Points | Assessment | Target |
|--------|--------|------------|--------|
| Code Documentation | 4 | Dart doc comments | > 60% coverage |
| README Quality | 3 | README completeness | Complete |
| Architecture Documentation | 3 | Tech docs | Complete |

### 7.2 Scoring Formulas

#### Code Documentation Score (4 points)

```dart
int calculateCodeDocScore({
  required double publicApiCoverage, // % with doc comments
  required double classDocCoverage,
  required double complexFunctionDocCoverage,
}) {
  double average = (publicApiCoverage + classDocCoverage + complexFunctionDocCoverage) / 3;
  
  if (average >= 80) return 4;
  if (average >= 60) return 3;
  if (average >= 40) return 2;
  if (average >= 20) return 1;
  return 0;
}
```

#### README Quality Score (3 points)

| Section | Required | Points |
|---------|----------|--------|
| Title & description | Yes | 0.5 |
| Installation | Yes | 0.5 |
| Usage | Yes | 0.5 |
| Features | No | 0.5 |
| Architecture | No | 0.5 |
| Contributing | No | 0.5 |

#### Architecture Documentation Score (3 points)

| Document | Required | Points |
|----------|----------|--------|
| Architecture overview | Yes | 1 |
| API contracts | Yes | 1 |
| Database schema | Yes | 0.5 |
| Deployment guide | No | 0.5 |

---

## 8. Total Score Calculation

### 8.1 Final Formula

```dart
class EngineeringScoreCalculator {
  static int calculateTotalScore(ScoreComponents components) {
    // Calculate individual scores
    int codeQuality = calculateCodeQualityScore(components.codeQuality);
    int performance = calculatePerformanceScore(components.performance);
    int security = calculateSecurityScore(components.security);
    int maintainability = calculateMaintainabilityScore(components.maintainability);
    int scalability = calculateScalabilityScore(components.scalability);
    int documentation = calculateDocumentationScore(components.documentation);
    
    // Weighted total
    double weightedTotal = 
      (codeQuality * 0.25) +
      (performance * 0.20) +
      (security * 0.20) +
      (maintainability * 0.15) +
      (scalability * 0.10) +
      (documentation * 0.10);
    
    return weightedTotal.round();
  }
  
  static String getGrade(int totalScore) {
    if (totalScore >= 90) return 'A+';
    if (totalScore >= 85) return 'A';
    if (totalScore >= 80) return 'A-';
    if (totalScore >= 75) return 'B+';
    if (totalScore >= 70) return 'B';
    if (totalScore >= 65) return 'B-';
    if (totalScore >= 60) return 'C+';
    if (totalScore >= 55) return 'C';
    if (totalScore >= 50) return 'C-';
    return 'F';
  }
  
  static String getAssessment(String grade) {
    return switch (grade) {
      'A+' || 'A' || 'A-' => 'Excellent - Production Ready',
      'B+' || 'B' || 'B-' => 'Good - Minor improvements needed',
      'C+' || 'C' || 'C-' => 'Acceptable - Significant improvements needed',
      _ => 'Poor - Major refactoring required',
    };
  }
}
```

### 8.2 Grade Interpretation

| Grade | Score Range | Assessment | Action Required |
|-------|-------------|------------|-----------------|
| **A+** | 90-100 | Exceptional | Maintain standards |
| **A** | 85-89 | Excellent | Minor polish |
| **A-** | 80-84 | Very Good | Address low-hanging fruit |
| **B+** | 75-79 | Good | Plan improvements |
| **B** | 70-74 | Acceptable | Address critical gaps |
| **B-** | 65-69 | Below Standard | Immediate action needed |
| **C+** | 60-64 | Poor | Major effort required |
| **C** | 55-59 | Very Poor | Consider refactor |
| **C-** | 50-54 | Critical | Halt new features |
| **F** | < 50 | Unacceptable | Complete overhaul |

---

## 9. Scoring Automation

### 9.1 CI/CD Integration

```yaml
# .github/workflows/quality-score.yml

name: Quality Score

on: [push, pull_request]

jobs:
  score:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Get dependencies
        run: flutter pub get
        
      - name: Run static analysis
        run: flutter analyze > analysis_results.txt
        
      - name: Check formatting
        run: dart format --set-exit-if-changed .
        
      - name: Run tests with coverage
        run: flutter test --coverage
        
      - name: Calculate score
        run: dart scripts/calculate_score.dart
        
      - name: Upload score report
        uses: actions/upload-artifact@v3
        with:
          name: quality-score-report
          path: score_report.json
```

### 9.2 Score Report Format

```json
{
  "timestamp": "2026-02-28T10:30:00Z",
  "version": "1.0.0",
  "total_score": 78,
  "grade": "B+",
  "assessment": "Good - Minor improvements needed",
  "breakdown": {
    "code_quality": {
      "score": 19,
      "max": 25,
      "percentage": 76,
      "details": {
        "static_analysis": 7,
        "code_style": 5,
        "complexity": 4,
        "duplication": 3,
        "naming": 0
      }
    },
    "performance": {
      "score": 16,
      "max": 20,
      "percentage": 80
    },
    "security": {
      "score": 18,
      "max": 20,
      "percentage": 90
    },
    "maintainability": {
      "score": 12,
      "max": 15,
      "percentage": 80
    },
    "scalability": {
      "score": 8,
      "max": 10,
      "percentage": 80
    },
    "documentation": {
      "score": 5,
      "max": 10,
      "percentage": 50
    }
  },
  "recommendations": [
    "Improve code documentation coverage (currently 45%)",
    "Reduce cyclomatic complexity in invoice_generator.dart",
    "Add missing doc comments to public APIs"
  ],
  "trend": {
    "previous_score": 75,
    "change": +3,
    "direction": "improving"
  }
}
```

---

**End of Document**
