<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTable from '@/components/ui/BaseTable.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import ictaLogo from '@/assets/icta-logo.png'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const user = computed(() => authStore.user)

const countyId = route.params.id
const county = ref(null)
const officers = ref([])
const submissions = ref([])
const isLoading = ref(true)
const isExportingPDF = ref(false)
const errorMessage = ref('')

const fetchCountyDetails = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    // Fetch all county data from the county-reports endpoint
    const reportsRes = await api.get('/submissions/county-reports')
    const allCounties = reportsRes.data
    
    // Find the specific county
    const countyData = allCounties.find(c => c.county.id === parseInt(countyId))
    
    if (!countyData) {
      errorMessage.value = 'County not found'
      return
    }
    
    county.value = {
      id: countyData.county.id,
      name: countyData.county.name,
      region: countyData.county.region,
      region_id: countyData.county.region_id,
      is_active: countyData.county.is_active,
      officers_count: countyData.county.officers_count,
      submissions_count: countyData.report.total_submissions,
      total_projects: countyData.report.total_projects
    }
    
    // Get submissions for this county
    submissions.value = countyData.report.submissions || []
    
    // Fetch officers for this county
    const usersRes = await api.get('/users')
    officers.value = usersRes.data.filter(u => u.county_id === parseInt(countyId) && u.role === 'COUNTY_OFFICER')
  } catch (err) {
    console.error('Failed to fetch county details:', err)
    errorMessage.value = 'Failed to load county details'
  } finally {
    isLoading.value = false
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-KE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const truncateText = (text, maxLength = 30) => {
  if (!text) return '-'
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

const getStatusColor = (status) => {
  const statusMap = {
    'UP': 'success',
    'DOWN': 'danger',
    'Stable': 'info',
    'Maintenance': 'warning',
    'Ongoing': 'warning',
    'Pending': 'info',
  }
  return statusMap[status] || 'neutral'
}

const generateCountyPDF = async () => {
  if (!county.value || submissions.value.length === 0) {
    alert('No data to export')
    return
  }

  isExportingPDF.value = true
  try {
    const doc = new jsPDF('p', 'mm', 'a4')
    const pageHeight = doc.internal.pageSize.height
    const pageWidth = doc.internal.pageSize.width
    const margin = 15
    const contentWidth = pageWidth - 2 * margin

    const colors = {
      black: [0, 0, 0],
      darkGray: [50, 50, 50],
      gray: [100, 100, 100],
      lightGray: [230, 230, 230],
      veryLightGray: [245, 245, 245],
      white: [255, 255, 255]
    }

    const addPageHeader = (pageNum) => {
      doc.setPage(pageNum)
      doc.setFillColor(245, 245, 245)
      doc.rect(0, 0, pageWidth, 32, 'F')
      
      doc.setFont('helvetica', 'bold')
      doc.setFontSize(11)
      doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
      doc.text('ICT AUTHORITY', margin, 7)
      
      doc.setFont('helvetica', 'normal')
      doc.setFontSize(7)
      doc.setTextColor(colors.gray[0], colors.gray[1], colors.gray[2])
      doc.text('Teleposta Towers, 12th Floor, Kenyatta Avenue', margin, 10)
      doc.text('PO Box 27150-00100, Nairobi, Kenya | Tel: +254 20 2089061 | www.icta.go.ke', margin, 13)
      
      try {
        if (ictaLogo) {
          doc.addImage(ictaLogo, 'PNG', pageWidth - margin - 22, 2, 22, 22)
        }
      } catch (e) {
        // Silent fail
      }
      
      doc.setDrawColor(0, 0, 0)
      doc.setLineWidth(0.5)
      doc.line(0, 32, pageWidth, 32)
    }

    const addPageFooter = (pageNum, totalPages) => {
      doc.setPage(pageNum)
      doc.setDrawColor(0, 0, 0)
      doc.setLineWidth(0.5)
      doc.line(margin, pageHeight - 12, pageWidth - margin, pageHeight - 12)
      
      doc.setFont('helvetica', 'normal')
      doc.setFontSize(8)
      doc.setTextColor(colors.gray[0], colors.gray[1], colors.gray[2])
      doc.text(`Page ${pageNum} of ${totalPages}`, margin, pageHeight - 8)
      doc.text(`Generated: ${new Date().toLocaleDateString('en-US')}`, pageWidth / 2 - 30, pageHeight - 8)
      doc.text(`ICT Authority`, pageWidth - margin - 40, pageHeight - 8, { align: 'right' })
    }

    // ===== COVER PAGE =====
    doc.setFillColor(255, 255, 255)
    doc.rect(0, 0, pageWidth, pageHeight, 'F')
    addPageHeader(1)
    
    let y = 50
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(22)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text(`${county.value.name} COUNTY REPORT`, pageWidth / 2, y, { align: 'center' })
    
    y += 15
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(14)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    doc.text('ICT PROJECT SUBMISSIONS', pageWidth / 2, y, { align: 'center' })
    
    y += 20
    
    // Stats box
    doc.setDrawColor(0, 0, 0)
    doc.setLineWidth(0.5)
    doc.rect(margin + 10, y, contentWidth - 20, 28)
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(9)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text(`Total Submissions: ${submissions.value.length}  |  County Officers: ${officers.value.length}`, pageWidth / 2, y + 7, { align: 'center' })
    doc.text(`Region: ${county.value.region}  |  Status: ${county.value.is_active ? 'ACTIVE' : 'INACTIVE'}`, pageWidth / 2, y + 15, { align: 'center' })
    
    y += 40
    
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(9)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    doc.text(`Generated: ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} | ${new Date().toLocaleTimeString('en-US')}`, pageWidth / 2, y, { align: 'center' })
    
    y += 15
    
    // Executive summary
    doc.setFillColor(230, 230, 230)
    doc.rect(margin + 5, y, contentWidth - 10, 40, 'F')
    doc.setDrawColor(0, 0, 0)
    doc.setLineWidth(0.5)
    doc.rect(margin + 5, y, contentWidth - 10, 40)
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(9)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text('EXECUTIVE SUMMARY', margin + 8, y + 4)
    
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(8)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    const summaryText = `This report contains a comprehensive overview of all ICT Authority project submissions for ${county.value.name} County in the ${county.value.region} region. The county has ${officers.value.length} active county officers managing ${submissions.value.length} project submissions across various phases and sites.`
    const splitSummary = doc.splitTextToSize(summaryText, contentWidth - 20)
    doc.text(splitSummary, margin + 8, y + 10)
    
    // ===== SUBMISSIONS PAGE =====
    doc.addPage()
    const pageNum = doc.internal.getNumberOfPages()
    addPageHeader(pageNum)
    
    y = 38
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(12)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text(`Submissions (${submissions.value.length})`, margin, y)
    
    y += 8
    
    if (submissions.value.length > 0) {
      const tableData = submissions.value.map((s) => [
        s.phase || 'N/A',
        s.site || 'N/A',
        s.project_type || 'N/A',
        s.status || 'UP',
        s.remarks ? s.remarks.substring(0, 30) + (s.remarks.length > 30 ? '...' : '') : '-'
      ])
      
      autoTable(doc, {
        startY: y,
        head: [['Phase', 'Site', 'Project Type', 'Status', 'Remarks']],
        body: tableData,
        theme: 'grid',
        margin: { left: margin, right: margin },
        headStyles: {
          fillColor: [0, 0, 0],
          textColor: [255, 255, 255],
          fontStyle: 'bold',
          fontSize: 8,
          cellPadding: 2.5,
          font: 'helvetica'
        },
        bodyStyles: {
          textColor: colors.darkGray,
          fontSize: 7,
          cellPadding: 2,
          font: 'helvetica'
        },
        alternateRowStyles: {
          fillColor: [245, 245, 245]
        },
        columnStyles: {
          0: { cellWidth: 18 },
          1: { cellWidth: 25 },
          2: { cellWidth: 25 },
          3: { cellWidth: 15 },
          4: { cellWidth: 47 }
        }
      })
    }

    // Add footers to all pages
    const totalPages = doc.internal.getNumberOfPages()
    for (let i = 1; i <= totalPages; i++) {
      addPageFooter(i, totalPages)
    }

    // Save
    try {
      const fileName = `${county.value.name}_County_Report_${new Date().getTime()}.pdf`
      doc.save(fileName)
    } catch (e) {
      // Fallback: use blob download
      const blob = doc.output('blob')
      const link = document.createElement('a')
      link.href = URL.createObjectURL(blob)
      link.download = `${county.value.name}_County_Report_${new Date().getTime()}.pdf`
      link.click()
      URL.revokeObjectURL(link.href)
    }
  } catch (error) {
    errorMessage.value = 'Failed to generate PDF: ' + error.message
    console.error('PDF generation error:', error)
  } finally {
    isExportingPDF.value = false
    if (errorMessage.value) {
      setTimeout(() => {
        errorMessage.value = ''
      }, 5000)
    }
  }
}

const goBack = () => {
  router.push('/region')
}

onMounted(() => {
  fetchCountyDetails()
})
</script>

<template>
  <div class="county-detail-view">
    <!-- Header -->
    <div class="header">
      <div class="header-content">
        <BaseButton variant="outline" size="sm" @click="goBack">← Back to Dashboard</BaseButton>
        <h1 v-if="county">{{ county.name }} County</h1>
      </div>
      <div class="header-actions">
        <BaseButton variant="outline" @click="fetchCountyDetails" :disabled="isLoading">
          {{ isLoading ? 'Loading...' : 'Refresh' }}
        </BaseButton>
        <BaseButton variant="primary" @click="generateCountyPDF" :disabled="isExportingPDF || !county">
          {{ isExportingPDF ? '⏳ Generating PDF...' : '📥 Download Report' }}
        </BaseButton>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="errorMessage" class="alert alert-error">
      {{ errorMessage }}
      <BaseButton variant="text" size="sm" @click="goBack">Back</BaseButton>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading county details...</p>
    </div>

    <!-- County Details -->
    <template v-else-if="county">
      <!-- Overview Stats -->
      <div class="stats-grid">
        <BaseCard>
          <div class="stat-item">
            <span class="stat-label">Region</span>
            <span class="stat-value">{{ county.region }}</span>
          </div>
        </BaseCard>
        <BaseCard>
          <div class="stat-item">
            <span class="stat-label">County Officers</span>
            <span class="stat-value">{{ county.officers_count }}</span>
          </div>
        </BaseCard>
        <BaseCard>
          <div class="stat-item">
            <span class="stat-label">Total Submissions</span>
            <span class="stat-value">{{ county.submissions_count }}</span>
          </div>
        </BaseCard>
        <BaseCard>
          <div class="stat-item">
            <span class="stat-label">Active Projects</span>
            <span class="stat-value">{{ county.total_projects }}</span>
          </div>
        </BaseCard>
        <BaseCard>
          <div class="stat-item">
            <span class="stat-label">Status</span>
            <span class="stat-value">
              <StatusBadge :status="county.is_active ? 'success' : 'danger'">
                {{ county.is_active ? 'ACTIVE' : 'INACTIVE' }}
              </StatusBadge>
            </span>
          </div>
        </BaseCard>
      </div>

      <!-- Recent Submissions -->
      <BaseCard style="margin-top: 2rem;">
        <template #header>
          <h3>Recent Submissions ({{ submissions.length }})</h3>
        </template>
        <div v-if="submissions.length === 0" class="empty-state">
          <p>No submissions for this county.</p>
        </div>
        <BaseTable v-else :columns="['Phase', 'Site', 'Project Type', 'Status', 'Remarks']">
          <tr v-for="submission in submissions" :key="submission.id">
            <td>{{ submission.phase || 'N/A' }}</td>
            <td class="font-bold">{{ submission.site }}</td>
            <td>{{ submission.project_type || 'N/A' }}</td>
            <td>
              <StatusBadge :status="getStatusColor(submission.status)">
                {{ submission.status }}
              </StatusBadge>
            </td>
            <td class="text-sm">{{ truncateText(submission.remarks || '-', 30) }}</td>
          </tr>
        </BaseTable>
      </BaseCard>
    </template>
  </div>
</template>

<style scoped>
.county-detail-view {
  padding: 2rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.header-content h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  border-left: 4px solid;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border-left-color: #fca5a5;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  gap: 1rem;
  color: #666;
}

.spinner {
  width: 2rem;
  height: 2rem;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.stat-item {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #6b7280;
  text-transform: uppercase;
  font-weight: 500;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: #1f2937;
}

.empty-state {
  padding: 2rem;
  text-align: center;
  color: #6b7280;
}

.officers-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.officer-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  background: #f9fafb;
}

.officer-info {
  flex: 1;
}

.officer-info h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  color: #1f2937;
}

.officer-email {
  margin: 0;
  font-size: 0.875rem;
  color: #6b7280;
}

.font-bold {
  font-weight: 600;
}

.text-sm {
  font-size: 0.875rem;
  color: #6b7280;
}

@media (max-width: 768px) {
  .county-detail-view {
    padding: 1rem;
  }

  .header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .officer-card {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
}
</style>
